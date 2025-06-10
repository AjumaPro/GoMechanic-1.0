from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.utils import timezone
from django.conf import settings
from django.core.mail import send_mail
from django.template.loader import render_to_string
import requests
import json
from .models import Notification, NotificationPreference, DeviceToken
from .serializers import (
    NotificationSerializer, NotificationCreateSerializer, NotificationUpdateSerializer,
    NotificationBulkUpdateSerializer, NotificationPreferenceSerializer, DeviceTokenSerializer
)

class NotificationViewSet(viewsets.ModelViewSet):
    serializer_class = NotificationSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Notification.objects.filter(recipient=self.request.user)

    def get_serializer_class(self):
        if self.action == 'create':
            return NotificationCreateSerializer
        elif self.action in ['update', 'partial_update']:
            return NotificationUpdateSerializer
        return NotificationSerializer

    def perform_create(self, serializer):
        notification = serializer.save(recipient=self.request.user)
        self._send_notification(notification)

    def _send_notification(self, notification):
        """Send notification through appropriate channels"""
        preferences = notification.recipient.notification_preferences
        
        # Check if notification should be sent based on preferences
        if not self._should_send_notification(notification, preferences):
            return

        # Send through enabled channels
        if preferences.push_enabled:
            self._send_push_notification(notification)
        if preferences.email_enabled:
            self._send_email_notification(notification)
        if preferences.sms_enabled:
            self._send_sms_notification(notification)
        if preferences.in_app_enabled:
            # In-app notifications are handled by the frontend
            pass

    def _should_send_notification(self, notification, preferences):
        """Check if notification should be sent based on preferences and quiet hours"""
        # Check notification type preferences
        if notification.notification_type.startswith('booking_') and not preferences.booking_updates:
            return False
        if notification.notification_type.startswith('payment_') and not preferences.payment_updates:
            return False
        if notification.notification_type == 'service_reminder' and not preferences.service_reminders:
            return False

        # Check quiet hours
        if preferences.quiet_hours_start and preferences.quiet_hours_end:
            current_time = timezone.now().time()
            if preferences.quiet_hours_start <= current_time <= preferences.quiet_hours_end:
                return False

        return True

    def _send_push_notification(self, notification):
        """Send push notification using Firebase Cloud Messaging"""
        device_tokens = DeviceToken.objects.filter(
            user=notification.recipient,
            is_active=True
        ).values_list('token', flat=True)

        if not device_tokens:
            return

        # Prepare FCM message
        message = {
            'message': {
                'token': device_tokens[0],  # Send to first device for now
                'notification': {
                    'title': notification.title,
                    'body': notification.message
                },
                'data': {
                    'type': notification.notification_type,
                    'booking_id': str(notification.booking.id) if notification.booking else '',
                    'payment_id': str(notification.payment.id) if notification.payment else ''
                }
            }
        }

        # Send to FCM
        headers = {
            'Authorization': f'key={settings.FCM_SERVER_KEY}',
            'Content-Type': 'application/json'
        }
        response = requests.post(
            'https://fcm.googleapis.com/v1/projects/{}/messages:send'.format(
                settings.FCM_PROJECT_ID
            ),
            headers=headers,
            data=json.dumps(message)
        )

        if response.status_code != 200:
            # Log error or handle failure
            pass

    def _send_email_notification(self, notification):
        """Send email notification"""
        context = {
            'notification': notification,
            'user': notification.recipient
        }
        
        # Render email templates
        subject = notification.title
        html_message = render_to_string(
            'notifications/email/notification.html',
            context
        )
        plain_message = render_to_string(
            'notifications/email/notification.txt',
            context
        )

        # Send email
        send_mail(
            subject=subject,
            message=plain_message,
            from_email=settings.DEFAULT_FROM_EMAIL,
            recipient_list=[notification.recipient.email],
            html_message=html_message
        )

    def _send_sms_notification(self, notification):
        """Send SMS notification using Twilio"""
        if not notification.recipient.phone_number:
            return

        # Prepare Twilio message
        message = {
            'To': notification.recipient.phone_number,
            'From': settings.TWILIO_PHONE_NUMBER,
            'Body': f"{notification.title}\n\n{notification.message}"
        }

        # Send SMS
        response = requests.post(
            f'https://api.twilio.com/2010-04-01/Accounts/{settings.TWILIO_ACCOUNT_SID}/Messages.json',
            auth=(settings.TWILIO_ACCOUNT_SID, settings.TWILIO_AUTH_TOKEN),
            data=message
        )

        if response.status_code != 201:
            # Log error or handle failure
            pass

    @action(detail=False, methods=['post'])
    def mark_all_read(self, request):
        """Mark all notifications as read"""
        self.get_queryset().update(
            is_read=True,
            read_at=timezone.now()
        )
        return Response({'status': 'success'})

    @action(detail=False, methods=['post'])
    def bulk_update(self, request):
        """Bulk update notification read status"""
        serializer = NotificationBulkUpdateSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        notification_ids = serializer.validated_data['notification_ids']
        is_read = serializer.validated_data['is_read']

        # Update notifications
        notifications = self.get_queryset().filter(id__in=notification_ids)
        notifications.update(
            is_read=is_read,
            read_at=timezone.now() if is_read else None
        )

        return Response({'status': 'success'})

class NotificationPreferenceViewSet(viewsets.ModelViewSet):
    serializer_class = NotificationPreferenceSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        # Get or create preferences for the current user
        preferences, created = NotificationPreference.objects.get_or_create(
            user=self.request.user
        )
        return preferences

    def get_queryset(self):
        return NotificationPreference.objects.filter(user=self.request.user)

class DeviceTokenViewSet(viewsets.ModelViewSet):
    serializer_class = DeviceTokenSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return DeviceToken.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user) 