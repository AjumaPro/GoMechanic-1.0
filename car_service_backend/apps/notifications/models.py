from django.db import models
from django.conf import settings
from apps.bookings.models import Booking
from apps.payments.models import Payment
from django.utils import timezone

class Notification(models.Model):
    NOTIFICATION_TYPE = (
        ('booking_created', 'Booking Created'),
        ('booking_accepted', 'Booking Accepted'),
        ('booking_in_progress', 'Booking In Progress'),
        ('booking_completed', 'Booking Completed'),
        ('booking_cancelled', 'Booking Cancelled'),
        ('payment_successful', 'Payment Successful'),
        ('payment_failed', 'Payment Failed'),
        ('invoice_generated', 'Invoice Generated'),
        ('mechanic_assigned', 'Mechanic Assigned'),
        ('mechanic_location', 'Mechanic Location Updated'),
        ('service_reminder', 'Service Reminder'),
    )

    CHANNEL_TYPE = (
        ('push', 'Push Notification'),
        ('email', 'Email'),
        ('sms', 'SMS'),
        ('in_app', 'In-App Notification'),
    )

    recipient = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE,
                                related_name='notifications')
    notification_type = models.CharField(max_length=50, choices=NOTIFICATION_TYPE)
    title = models.CharField(max_length=255)
    message = models.TextField()
    channel = models.CharField(max_length=20, choices=CHANNEL_TYPE)
    is_read = models.BooleanField(default=False)
    read_at = models.DateTimeField(null=True, blank=True)
    booking = models.ForeignKey(Booking, on_delete=models.CASCADE, null=True, blank=True,
                              related_name='notifications')
    payment = models.ForeignKey(Payment, on_delete=models.CASCADE, null=True, blank=True,
                              related_name='notifications')
    metadata = models.JSONField(default=dict, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.notification_type} - {self.recipient.username}"

    def mark_as_read(self):
        if not self.is_read:
            self.is_read = True
            self.read_at = timezone.now()
            self.save()

class NotificationPreference(models.Model):
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE,
                              related_name='notification_preferences')
    push_enabled = models.BooleanField(default=True)
    email_enabled = models.BooleanField(default=True)
    sms_enabled = models.BooleanField(default=True)
    in_app_enabled = models.BooleanField(default=True)
    booking_updates = models.BooleanField(default=True)
    payment_updates = models.BooleanField(default=True)
    service_reminders = models.BooleanField(default=True)
    marketing_updates = models.BooleanField(default=False)
    quiet_hours_start = models.TimeField(null=True, blank=True)
    quiet_hours_end = models.TimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-updated_at']

    def __str__(self):
        return f"Notification Preferences - {self.user.username}"

class DeviceToken(models.Model):
    DEVICE_TYPE = (
        ('ios', 'iOS'),
        ('android', 'Android'),
        ('web', 'Web'),
    )

    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE,
                           related_name='device_tokens')
    device_type = models.CharField(max_length=20, choices=DEVICE_TYPE)
    token = models.CharField(max_length=255, unique=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-updated_at']
        unique_together = ('user', 'token')

    def __str__(self):
        return f"{self.device_type} - {self.user.username}" 