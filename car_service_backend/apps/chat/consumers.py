import json
from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async
from django.contrib.auth import get_user_model
from .models import ChatRoom, Message, MessageReadStatus, TypingStatus, MessageReaction
from django.utils import timezone

User = get_user_model()

class ChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        """Handle WebSocket connection"""
        self.user = self.scope["user"]
        if not self.user.is_authenticated:
            await self.close()
            return

        # Join user's personal channel
        await self.channel_layer.group_add(
            f"user_{self.user.id}",
            self.channel_name
        )

        await self.accept()

    async def disconnect(self, close_code):
        """Handle WebSocket disconnection"""
        # Leave user's personal channel
        await self.channel_layer.group_discard(
            f"user_{self.user.id}",
            self.channel_name
        )

    async def receive(self, text_data):
        """Handle incoming WebSocket messages"""
        try:
            data = json.loads(text_data)
            message_type = data.get('type')
            
            if message_type == 'join_room':
                await self._handle_join_room(data)
            elif message_type == 'leave_room':
                await self._handle_leave_room(data)
            elif message_type == 'chat_message':
                await self._handle_chat_message(data)
            elif message_type == 'typing_status':
                await self._handle_typing_status(data)
            elif message_type == 'mark_read':
                await self._handle_mark_read(data)
            elif message_type == 'delete_message':
                await self._handle_delete_message(data)
            elif message_type == 'add_reaction':
                await self._handle_add_reaction(data)
            elif message_type == 'remove_reaction':
                await self._handle_remove_reaction(data)
            elif message_type == 'archive_room':
                await self._handle_archive_room(data)
            elif message_type == 'unarchive_room':
                await self._handle_unarchive_room(data)
        except Exception as e:
            await self.send(text_data=json.dumps({
                'type': 'error',
                'message': str(e)
            }))

    async def _handle_join_room(self, data):
        """Handle joining a chat room"""
        chat_room_id = data.get('chat_room_id')
        if not chat_room_id:
            return

        # Join room group
        await self.channel_layer.group_add(
            f"chat_{chat_room_id}",
            self.channel_name
        )

        # Send confirmation
        await self.send(text_data=json.dumps({
            'type': 'room_joined',
            'chat_room_id': chat_room_id
        }))

    async def _handle_leave_room(self, data):
        """Handle leaving a chat room"""
        chat_room_id = data.get('chat_room_id')
        if not chat_room_id:
            return

        # Leave room group
        await self.channel_layer.group_discard(
            f"chat_{chat_room_id}",
            self.channel_name
        )

        # Send confirmation
        await self.send(text_data=json.dumps({
            'type': 'room_left',
            'chat_room_id': chat_room_id
        }))

    async def _handle_chat_message(self, data):
        """Handle incoming chat message"""
        chat_room_id = data.get('chat_room_id')
        content = data.get('content')
        message_type = data.get('message_type', 'text')
        
        if not all([chat_room_id, content]):
            return

        # Save message to database
        message = await self._save_message(chat_room_id, content, message_type)
        if not message:
            return

        # Broadcast message to room group
        await self.channel_layer.group_send(
            f"chat_{chat_room_id}",
            {
                'type': 'chat.message',
                'message': {
                    'id': message.id,
                    'sender_id': message.sender.id,
                    'content': message.content,
                    'message_type': message.message_type,
                    'created_at': message.created_at.isoformat()
                }
            }
        )

    async def _handle_typing_status(self, data):
        """Handle typing status update"""
        chat_room_id = data.get('chat_room_id')
        is_typing = data.get('is_typing', False)
        
        if not chat_room_id:
            return

        # Update typing status in database
        typing_status = await self._update_typing_status(chat_room_id, is_typing)
        if not typing_status:
            return

        # Broadcast typing status to room group
        await self.channel_layer.group_send(
            f"chat_{chat_room_id}",
            {
                'type': 'chat.typing',
                'message': {
                    'user_id': typing_status.user.id,
                    'is_typing': typing_status.is_typing
                }
            }
        )

    async def _handle_mark_read(self, data):
        """Handle marking messages as read"""
        message_id = data.get('message_id')
        if not message_id:
            return

        # Update read status in database
        await self._update_read_status(message_id)

    async def _handle_delete_message(self, data):
        """Handle message deletion"""
        message_id = data.get('message_id')
        if not message_id:
            return

        # Delete message in database
        message = await self._delete_message(message_id)
        if not message:
            return

        # Broadcast message deletion to room group
        await self.channel_layer.group_send(
            f"chat_{message.chat_room.id}",
            {
                'type': 'chat.message_deleted',
                'message': {
                    'message_id': message.id,
                    'deleted_by': message.deleted_by.id
                }
            }
        )

    async def _handle_add_reaction(self, data):
        """Handle adding a reaction"""
        message_id = data.get('message_id')
        reaction_type = data.get('reaction_type')
        
        if not all([message_id, reaction_type]):
            return

        # Add reaction in database
        reaction = await self._add_reaction(message_id, reaction_type)
        if not reaction:
            return

        # Broadcast reaction to room group
        await self.channel_layer.group_send(
            f"chat_{reaction.message.chat_room.id}",
            {
                'type': 'chat.reaction_added',
                'message': {
                    'message_id': reaction.message.id,
                    'reaction': {
                        'id': reaction.id,
                        'user_id': reaction.user.id,
                        'reaction_type': reaction.reaction_type
                    }
                }
            }
        )

    async def _handle_remove_reaction(self, data):
        """Handle removing a reaction"""
        message_id = data.get('message_id')
        reaction_type = data.get('reaction_type')
        
        if not all([message_id, reaction_type]):
            return

        # Remove reaction in database
        message = await self._remove_reaction(message_id, reaction_type)
        if not message:
            return

        # Broadcast reaction removal to room group
        await self.channel_layer.group_send(
            f"chat_{message.chat_room.id}",
            {
                'type': 'chat.reaction_removed',
                'message': {
                    'message_id': message.id,
                    'user_id': self.user.id,
                    'reaction_type': reaction_type
                }
            }
        )

    async def _handle_archive_room(self, data):
        """Handle archiving a chat room"""
        chat_room_id = data.get('chat_room_id')
        if not chat_room_id:
            return

        # Archive chat room in database
        chat_room = await self._archive_room(chat_room_id)
        if not chat_room:
            return

        # Broadcast archive to room group
        await self.channel_layer.group_send(
            f"chat_{chat_room_id}",
            {
                'type': 'chat.room_archived',
                'message': {
                    'chat_room_id': chat_room.id,
                    'archived_by': chat_room.archived_by.id
                }
            }
        )

    async def _handle_unarchive_room(self, data):
        """Handle unarchiving a chat room"""
        chat_room_id = data.get('chat_room_id')
        if not chat_room_id:
            return

        # Unarchive chat room in database
        chat_room = await self._unarchive_room(chat_room_id)
        if not chat_room:
            return

        # Broadcast unarchive to room group
        await self.channel_layer.group_send(
            f"chat_{chat_room_id}",
            {
                'type': 'chat.room_unarchived',
                'message': {
                    'chat_room_id': chat_room.id
                }
            }
        )

    @database_sync_to_async
    def _save_message(self, chat_room_id, content, message_type):
        """Save message to database"""
        try:
            chat_room = ChatRoom.objects.get(id=chat_room_id)
            if self.user not in chat_room.participants.all():
                return None

            message = Message.objects.create(
                chat_room=chat_room,
                sender=self.user,
                content=content,
                message_type=message_type
            )

            # Create read status for other participants
            for participant in chat_room.participants.exclude(id=self.user.id):
                MessageReadStatus.objects.create(
                    message=message,
                    user=participant
                )

            return message
        except ChatRoom.DoesNotExist:
            return None

    @database_sync_to_async
    def _update_typing_status(self, chat_room_id, is_typing):
        """Update typing status in database"""
        try:
            chat_room = ChatRoom.objects.get(id=chat_room_id)
            if self.user not in chat_room.participants.all():
                return None

            typing_status, created = TypingStatus.objects.update_or_create(
                chat_room=chat_room,
                user=self.user,
                defaults={'is_typing': is_typing}
            )

            return typing_status
        except ChatRoom.DoesNotExist:
            return None

    @database_sync_to_async
    def _update_read_status(self, message_id):
        """Update message read status in database"""
        try:
            message = Message.objects.get(id=message_id)
            if self.user not in message.chat_room.participants.all():
                return

            read_status, created = MessageReadStatus.objects.update_or_create(
                message=message,
                user=self.user,
                defaults={
                    'is_read': True,
                    'read_at': timezone.now()
                }
            )

            # Update message read status if all participants have read it
            all_read = not message.read_statuses.filter(is_read=False).exists()
            if all_read and not message.is_read:
                message.is_read = True
                message.read_at = timezone.now()
                message.save()
        except Message.DoesNotExist:
            pass

    @database_sync_to_async
    def _delete_message(self, message_id):
        """Delete message in database"""
        try:
            message = Message.objects.get(id=message_id)
            if self.user not in message.chat_room.participants.all():
                return None

            message.delete_message(self.user)
            return message
        except Message.DoesNotExist:
            return None

    @database_sync_to_async
    def _add_reaction(self, message_id, reaction_type):
        """Add reaction in database"""
        try:
            message = Message.objects.get(id=message_id)
            if self.user not in message.chat_room.participants.all():
                return None

            reaction, created = MessageReaction.objects.update_or_create(
                message=message,
                user=self.user,
                defaults={'reaction_type': reaction_type}
            )

            return reaction
        except Message.DoesNotExist:
            return None

    @database_sync_to_async
    def _remove_reaction(self, message_id, reaction_type):
        """Remove reaction in database"""
        try:
            message = Message.objects.get(id=message_id)
            if self.user not in message.chat_room.participants.all():
                return None

            reaction = MessageReaction.objects.get(
                message=message,
                user=self.user,
                reaction_type=reaction_type
            )
            reaction.delete()

            return message
        except (Message.DoesNotExist, MessageReaction.DoesNotExist):
            return None

    @database_sync_to_async
    def _archive_room(self, chat_room_id):
        """Archive chat room in database"""
        try:
            chat_room = ChatRoom.objects.get(id=chat_room_id)
            if self.user not in chat_room.participants.all():
                return None

            chat_room.archive(self.user)
            return chat_room
        except ChatRoom.DoesNotExist:
            return None

    @database_sync_to_async
    def _unarchive_room(self, chat_room_id):
        """Unarchive chat room in database"""
        try:
            chat_room = ChatRoom.objects.get(id=chat_room_id)
            if self.user not in chat_room.participants.all():
                return None

            chat_room.unarchive()
            return chat_room
        except ChatRoom.DoesNotExist:
            return None

    async def chat_message(self, event):
        """Handle chat message event"""
        await self.send(text_data=json.dumps({
            'type': 'chat.message',
            'message': event['message']
        }))

    async def chat_typing(self, event):
        """Handle typing status event"""
        await self.send(text_data=json.dumps({
            'type': 'chat.typing',
            'message': event['message']
        }))

    async def chat_message_deleted(self, event):
        """Handle message deleted event"""
        await self.send(text_data=json.dumps({
            'type': 'chat.message_deleted',
            'message': event['message']
        }))

    async def chat_reaction_added(self, event):
        """Handle reaction added event"""
        await self.send(text_data=json.dumps({
            'type': 'chat.reaction_added',
            'message': event['message']
        }))

    async def chat_reaction_removed(self, event):
        """Handle reaction removed event"""
        await self.send(text_data=json.dumps({
            'type': 'chat.reaction_removed',
            'message': event['message']
        }))

    async def chat_room_archived(self, event):
        """Handle room archived event"""
        await self.send(text_data=json.dumps({
            'type': 'chat.room_archived',
            'message': event['message']
        }))

    async def chat_room_unarchived(self, event):
        """Handle room unarchived event"""
        await self.send(text_data=json.dumps({
            'type': 'chat.room_unarchived',
            'message': event['message']
        })) 