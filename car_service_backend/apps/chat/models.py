from django.db import models
from django.conf import settings
from apps.bookings.models import Booking
from django.utils import timezone

class ChatRoom(models.Model):
    ROOM_TYPE = (
        ('booking', 'Booking Chat'),
        ('support', 'Support Chat'),
    )

    booking = models.ForeignKey(Booking, on_delete=models.CASCADE, null=True, blank=True,
                              related_name='chat_rooms')
    room_type = models.CharField(max_length=20, choices=ROOM_TYPE, default='booking')
    participants = models.ManyToManyField(settings.AUTH_USER_MODEL, related_name='chat_rooms')
    is_active = models.BooleanField(default=True)
    is_archived = models.BooleanField(default=False)
    archived_at = models.DateTimeField(null=True, blank=True)
    archived_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL,
                                  null=True, blank=True, related_name='archived_chat_rooms')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-updated_at']

    def __str__(self):
        if self.booking:
            return f"Chat Room - Booking #{self.booking.id}"
        return f"Chat Room - {self.room_type}"

    def get_other_participant(self, user):
        """Get the other participant in the chat room"""
        return self.participants.exclude(id=user.id).first()

    def archive(self, user):
        """Archive the chat room"""
        self.is_archived = True
        self.archived_at = timezone.now()
        self.archived_by = user
        self.save()

    def unarchive(self):
        """Unarchive the chat room"""
        self.is_archived = False
        self.archived_at = None
        self.archived_by = None
        self.save()

class Message(models.Model):
    MESSAGE_TYPE = (
        ('text', 'Text'),
        ('image', 'Image'),
        ('file', 'File'),
        ('location', 'Location'),
    )

    chat_room = models.ForeignKey(ChatRoom, on_delete=models.CASCADE, related_name='messages')
    sender = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE,
                             related_name='sent_messages')
    message_type = models.CharField(max_length=20, choices=MESSAGE_TYPE, default='text')
    content = models.TextField()
    file_url = models.URLField(null=True, blank=True)
    file_name = models.CharField(max_length=255, null=True, blank=True)
    file_size = models.IntegerField(null=True, blank=True)
    file_type = models.CharField(max_length=100, null=True, blank=True)
    latitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    longitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    is_read = models.BooleanField(default=False)
    read_at = models.DateTimeField(null=True, blank=True)
    is_deleted = models.BooleanField(default=False)
    deleted_at = models.DateTimeField(null=True, blank=True)
    deleted_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL,
                                 null=True, blank=True, related_name='deleted_messages')
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['created_at']

    def __str__(self):
        return f"Message from {self.sender.username} - {self.created_at}"

    def delete_message(self, user):
        """Soft delete the message"""
        self.is_deleted = True
        self.deleted_at = timezone.now()
        self.deleted_by = user
        self.save()

class MessageReaction(models.Model):
    REACTION_TYPES = (
        ('like', '👍'),
        ('love', '❤️'),
        ('laugh', '😄'),
        ('wow', '😮'),
        ('sad', '😢'),
        ('angry', '😠'),
    )

    message = models.ForeignKey(Message, on_delete=models.CASCADE, related_name='reactions')
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE,
                           related_name='message_reactions')
    reaction_type = models.CharField(max_length=20, choices=REACTION_TYPES)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']
        unique_together = ('message', 'user', 'reaction_type')

    def __str__(self):
        return f"{self.user.username} - {self.reaction_type} on {self.message}"

class MessageReadStatus(models.Model):
    message = models.ForeignKey(Message, on_delete=models.CASCADE, related_name='read_statuses')
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE,
                           related_name='message_read_statuses')
    is_read = models.BooleanField(default=False)
    read_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']
        unique_together = ('message', 'user')

    def __str__(self):
        return f"{self.user.username} - {self.message}"

class TypingStatus(models.Model):
    chat_room = models.ForeignKey(ChatRoom, on_delete=models.CASCADE, related_name='typing_statuses')
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE,
                           related_name='typing_statuses')
    is_typing = models.BooleanField(default=False)
    last_typed_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-last_typed_at']
        unique_together = ('chat_room', 'user')

    def __str__(self):
        return f"{self.user.username} - {'typing' if self.is_typing else 'not typing'}" 