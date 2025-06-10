from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.utils import timezone
from django.db.models import Q
from channels.layers import get_channel_layer
from asgiref.sync import async_to_sync
import json
from .models import ChatRoom, Message, MessageReadStatus, TypingStatus, MessageReaction
from .serializers import (
    ChatRoomSerializer, ChatRoomCreateSerializer, ChatRoomArchiveSerializer,
    MessageSerializer, MessageCreateSerializer, MessageReactionSerializer,
    MessageReactionCreateSerializer, TypingStatusSerializer, TypingStatusUpdateSerializer
)

class ChatRoomViewSet(viewsets.ModelViewSet):
    serializer_class = ChatRoomSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return ChatRoom.objects.filter(participants=self.request.user)

    def get_serializer_class(self):
        if self.action == 'create':
            return ChatRoomCreateSerializer
        elif self.action in ['archive', 'unarchive']:
            return ChatRoomArchiveSerializer
        return ChatRoomSerializer

    def perform_create(self, serializer):
        chat_room = serializer.save()
        # Add current user as participant
        chat_room.participants.add(self.request.user)
        # Notify other participants
        self._notify_chat_room_created(chat_room)

    def _notify_chat_room_created(self, chat_room):
        """Notify participants about new chat room"""
        channel_layer = get_channel_layer()
        for participant in chat_room.participants.all():
            async_to_sync(channel_layer.group_send)(
                f"user_{participant.id}",
                {
                    "type": "chat.room_created",
                    "message": {
                        "chat_room_id": chat_room.id,
                        "room_type": chat_room.room_type,
                        "booking_id": chat_room.booking.id if chat_room.booking else None
                    }
                }
            )

    @action(detail=True, methods=['post'])
    def archive(self, request, pk=None):
        """Archive a chat room"""
        chat_room = self.get_object()
        chat_room.archive(request.user)
        self._notify_chat_room_archived(chat_room)
        return Response({'status': 'success'})

    @action(detail=True, methods=['post'])
    def unarchive(self, request, pk=None):
        """Unarchive a chat room"""
        chat_room = self.get_object()
        chat_room.unarchive()
        self._notify_chat_room_unarchived(chat_room)
        return Response({'status': 'success'})

    def _notify_chat_room_archived(self, chat_room):
        """Notify participants about chat room being archived"""
        channel_layer = get_channel_layer()
        for participant in chat_room.participants.all():
            async_to_sync(channel_layer.group_send)(
                f"user_{participant.id}",
                {
                    "type": "chat.room_archived",
                    "message": {
                        "chat_room_id": chat_room.id,
                        "archived_by": chat_room.archived_by.id
                    }
                }
            )

    def _notify_chat_room_unarchived(self, chat_room):
        """Notify participants about chat room being unarchived"""
        channel_layer = get_channel_layer()
        for participant in chat_room.participants.all():
            async_to_sync(channel_layer.group_send)(
                f"user_{participant.id}",
                {
                    "type": "chat.room_unarchived",
                    "message": {
                        "chat_room_id": chat_room.id
                    }
                }
            )

    @action(detail=True, methods=['get'])
    def messages(self, request, pk=None):
        """Get messages for a chat room"""
        chat_room = self.get_object()
        messages = chat_room.messages.filter(is_deleted=False)
        serializer = MessageSerializer(messages, many=True)
        return Response(serializer.data)

    @action(detail=True, methods=['post'])
    def mark_read(self, request, pk=None):
        """Mark all messages in chat room as read"""
        chat_room = self.get_object()
        messages = chat_room.messages.filter(
            is_read=False,
            is_deleted=False
        ).exclude(
            sender=request.user
        )
        
        for message in messages:
            MessageReadStatus.objects.update_or_create(
                message=message,
                user=request.user,
                defaults={
                    'is_read': True,
                    'read_at': timezone.now()
                }
            )
            message.is_read = True
            message.read_at = timezone.now()
            message.save()

        return Response({'status': 'success'})

class MessageViewSet(viewsets.ModelViewSet):
    serializer_class = MessageSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Message.objects.filter(
            chat_room__participants=self.request.user,
            is_deleted=False
        )

    def get_serializer_class(self):
        if self.action == 'create':
            return MessageCreateSerializer
        elif self.action == 'add_reaction':
            return MessageReactionCreateSerializer
        return MessageSerializer

    def perform_create(self, serializer):
        message = serializer.save(sender=self.request.user)
        # Create read status for other participants
        self._create_read_statuses(message)
        # Notify participants
        self._notify_message_created(message)

    def _create_read_statuses(self, message):
        """Create read status for all participants except sender"""
        for participant in message.chat_room.participants.exclude(id=message.sender.id):
            MessageReadStatus.objects.create(
                message=message,
                user=participant
            )

    def _notify_message_created(self, message):
        """Notify participants about new message"""
        channel_layer = get_channel_layer()
        for participant in message.chat_room.participants.all():
            async_to_sync(channel_layer.group_send)(
                f"user_{participant.id}",
                {
                    "type": "chat.message",
                    "message": {
                        "chat_room_id": message.chat_room.id,
                        "message_id": message.id,
                        "sender_id": message.sender.id,
                        "content": message.content,
                        "message_type": message.message_type,
                        "created_at": message.created_at.isoformat()
                    }
                }
            )

    @action(detail=True, methods=['post'])
    def delete(self, request, pk=None):
        """Soft delete a message"""
        message = self.get_object()
        message.delete_message(request.user)
        self._notify_message_deleted(message)
        return Response({'status': 'success'})

    def _notify_message_deleted(self, message):
        """Notify participants about message being deleted"""
        channel_layer = get_channel_layer()
        for participant in message.chat_room.participants.all():
            async_to_sync(channel_layer.group_send)(
                f"user_{participant.id}",
                {
                    "type": "chat.message_deleted",
                    "message": {
                        "chat_room_id": message.chat_room.id,
                        "message_id": message.id,
                        "deleted_by": message.deleted_by.id
                    }
                }
            )

    @action(detail=True, methods=['post'])
    def add_reaction(self, request, pk=None):
        """Add a reaction to a message"""
        message = self.get_object()
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        reaction, created = MessageReaction.objects.update_or_create(
            message=message,
            user=request.user,
            defaults={'reaction_type': serializer.validated_data['reaction_type']}
        )

        self._notify_reaction_added(message, reaction)
        return Response(MessageReactionSerializer(reaction).data)

    @action(detail=True, methods=['post'])
    def remove_reaction(self, request, pk=None):
        """Remove a reaction from a message"""
        message = self.get_object()
        reaction_type = request.data.get('reaction_type')
        
        try:
            reaction = MessageReaction.objects.get(
                message=message,
                user=request.user,
                reaction_type=reaction_type
            )
            reaction.delete()
            self._notify_reaction_removed(message, reaction_type)
            return Response({'status': 'success'})
        except MessageReaction.DoesNotExist:
            return Response(
                {'error': 'Reaction not found'},
                status=status.HTTP_404_NOT_FOUND
            )

    def _notify_reaction_added(self, message, reaction):
        """Notify participants about reaction being added"""
        channel_layer = get_channel_layer()
        for participant in message.chat_room.participants.all():
            async_to_sync(channel_layer.group_send)(
                f"user_{participant.id}",
                {
                    "type": "chat.reaction_added",
                    "message": {
                        "chat_room_id": message.chat_room.id,
                        "message_id": message.id,
                        "reaction": {
                            "id": reaction.id,
                            "user_id": reaction.user.id,
                            "reaction_type": reaction.reaction_type
                        }
                    }
                }
            )

    def _notify_reaction_removed(self, message, reaction_type):
        """Notify participants about reaction being removed"""
        channel_layer = get_channel_layer()
        for participant in message.chat_room.participants.all():
            async_to_sync(channel_layer.group_send)(
                f"user_{participant.id}",
                {
                    "type": "chat.reaction_removed",
                    "message": {
                        "chat_room_id": message.chat_room.id,
                        "message_id": message.id,
                        "user_id": self.request.user.id,
                        "reaction_type": reaction_type
                    }
                }
            )

    @action(detail=True, methods=['post'])
    def mark_read(self, request, pk=None):
        """Mark message as read"""
        message = self.get_object()
        read_status, created = MessageReadStatus.objects.get_or_create(
            message=message,
            user=request.user,
            defaults={
                'is_read': True,
                'read_at': timezone.now()
            }
        )
        
        if not created and not read_status.is_read:
            read_status.is_read = True
            read_status.read_at = timezone.now()
            read_status.save()

        # Update message read status if all participants have read it
        all_read = not message.read_statuses.filter(is_read=False).exists()
        if all_read and not message.is_read:
            message.is_read = True
            message.read_at = timezone.now()
            message.save()

        return Response({'status': 'success'})

class TypingStatusViewSet(viewsets.ModelViewSet):
    serializer_class = TypingStatusSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return TypingStatus.objects.filter(
            chat_room__participants=self.request.user
        )

    def get_serializer_class(self):
        if self.action in ['update', 'partial_update']:
            return TypingStatusUpdateSerializer
        return TypingStatusSerializer

    def perform_create(self, serializer):
        typing_status = serializer.save(user=self.request.user)
        self._notify_typing_status(typing_status)

    def perform_update(self, serializer):
        typing_status = serializer.save()
        self._notify_typing_status(typing_status)

    def _notify_typing_status(self, typing_status):
        """Notify participants about typing status"""
        channel_layer = get_channel_layer()
        for participant in typing_status.chat_room.participants.exclude(id=typing_status.user.id):
            async_to_sync(channel_layer.group_send)(
                f"user_{participant.id}",
                {
                    "type": "chat.typing",
                    "message": {
                        "chat_room_id": typing_status.chat_room.id,
                        "user_id": typing_status.user.id,
                        "is_typing": typing_status.is_typing
                    }
                }
            ) 