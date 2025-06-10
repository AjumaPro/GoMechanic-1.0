from rest_framework import serializers
from .models import ChatRoom, Message, MessageReadStatus, TypingStatus, MessageReaction
from apps.users.serializers import UserSerializer
from apps.bookings.serializers import BookingSerializer

class MessageReactionSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)

    class Meta:
        model = MessageReaction
        fields = ('id', 'user', 'reaction_type', 'created_at')
        read_only_fields = ('id', 'created_at')

class MessageReadStatusSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)

    class Meta:
        model = MessageReadStatus
        fields = ('id', 'user', 'is_read', 'read_at', 'created_at')
        read_only_fields = ('id', 'created_at')

class MessageSerializer(serializers.ModelSerializer):
    sender = UserSerializer(read_only=True)
    read_statuses = MessageReadStatusSerializer(many=True, read_only=True)
    reactions = MessageReactionSerializer(many=True, read_only=True)
    deleted_by = UserSerializer(read_only=True)

    class Meta:
        model = Message
        fields = ('id', 'chat_room', 'sender', 'message_type', 'content',
                 'file_url', 'file_name', 'file_size', 'file_type',
                 'latitude', 'longitude', 'is_read', 'read_at',
                 'read_statuses', 'reactions', 'is_deleted', 'deleted_at',
                 'deleted_by', 'created_at')
        read_only_fields = ('id', 'sender', 'is_read', 'read_at', 'is_deleted',
                          'deleted_at', 'deleted_by', 'created_at')

class MessageCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Message
        fields = ('chat_room', 'message_type', 'content', 'file_url',
                 'file_name', 'file_size', 'file_type', 'latitude',
                 'longitude')

class MessageReactionCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = MessageReaction
        fields = ('reaction_type',)

class ChatRoomSerializer(serializers.ModelSerializer):
    participants = UserSerializer(many=True, read_only=True)
    booking = BookingSerializer(read_only=True)
    last_message = serializers.SerializerMethodField()
    unread_count = serializers.SerializerMethodField()
    archived_by = UserSerializer(read_only=True)

    class Meta:
        model = ChatRoom
        fields = ('id', 'booking', 'room_type', 'participants', 'is_active',
                 'is_archived', 'archived_at', 'archived_by', 'last_message',
                 'unread_count', 'created_at', 'updated_at')
        read_only_fields = ('id', 'created_at', 'updated_at')

    def get_last_message(self, obj):
        last_message = obj.messages.filter(is_deleted=False).last()
        if last_message:
            return MessageSerializer(last_message).data
        return None

    def get_unread_count(self, obj):
        user = self.context['request'].user
        return obj.messages.filter(
            is_read=False,
            is_deleted=False
        ).exclude(
            sender=user
        ).count()

class ChatRoomCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = ChatRoom
        fields = ('booking', 'room_type', 'participants')

class ChatRoomArchiveSerializer(serializers.ModelSerializer):
    class Meta:
        model = ChatRoom
        fields = ('is_archived',)

class TypingStatusSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)

    class Meta:
        model = TypingStatus
        fields = ('id', 'chat_room', 'user', 'is_typing', 'last_typed_at')
        read_only_fields = ('id', 'last_typed_at')

class TypingStatusUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = TypingStatus
        fields = ('is_typing',) 