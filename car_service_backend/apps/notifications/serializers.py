from rest_framework import serializers
from .models import Notification, NotificationPreference, DeviceToken
from apps.bookings.serializers import BookingSerializer
from apps.payments.serializers import PaymentSerializer

class DeviceTokenSerializer(serializers.ModelSerializer):
    class Meta:
        model = DeviceToken
        fields = ('id', 'device_type', 'token', 'is_active', 'created_at', 'updated_at')
        read_only_fields = ('id', 'created_at', 'updated_at')

class NotificationPreferenceSerializer(serializers.ModelSerializer):
    class Meta:
        model = NotificationPreference
        fields = ('id', 'push_enabled', 'email_enabled', 'sms_enabled',
                 'in_app_enabled', 'booking_updates', 'payment_updates',
                 'service_reminders', 'marketing_updates', 'quiet_hours_start',
                 'quiet_hours_end', 'created_at', 'updated_at')
        read_only_fields = ('id', 'created_at', 'updated_at')

class NotificationSerializer(serializers.ModelSerializer):
    booking = BookingSerializer(read_only=True)
    payment = PaymentSerializer(read_only=True)

    class Meta:
        model = Notification
        fields = ('id', 'recipient', 'notification_type', 'title', 'message',
                 'channel', 'is_read', 'read_at', 'booking', 'payment',
                 'metadata', 'created_at')
        read_only_fields = ('id', 'recipient', 'created_at', 'read_at')

class NotificationCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notification
        fields = ('notification_type', 'title', 'message', 'channel',
                 'booking', 'payment', 'metadata')

class NotificationUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notification
        fields = ('is_read',)
        read_only_fields = ('is_read',)

class NotificationBulkUpdateSerializer(serializers.Serializer):
    notification_ids = serializers.ListField(
        child=serializers.IntegerField(),
        min_length=1
    )
    is_read = serializers.BooleanField() 