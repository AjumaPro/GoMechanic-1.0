from django.db import models
from django.conf import settings
from apps.bookings.models import Booking

class Payment(models.Model):
    PAYMENT_STATUS = (
        ('pending', 'Pending'),
        ('processing', 'Processing'),
        ('completed', 'Completed'),
        ('failed', 'Failed'),
        ('refunded', 'Refunded'),
    )

    PAYMENT_METHOD = (
        ('card', 'Card'),
        ('bank_transfer', 'Bank Transfer'),
        ('wallet', 'Wallet'),
    )

    booking = models.ForeignKey(Booking, on_delete=models.CASCADE, related_name='payments')
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    currency = models.CharField(max_length=3, default='NGN')
    payment_method = models.CharField(max_length=20, choices=PAYMENT_METHOD)
    status = models.CharField(max_length=20, choices=PAYMENT_STATUS, default='pending')
    reference = models.CharField(max_length=100, unique=True)
    payment_provider = models.CharField(max_length=50)  # e.g., 'paystack', 'flutterwave'
    payment_provider_reference = models.CharField(max_length=100, blank=True)
    metadata = models.JSONField(default=dict, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"Payment {self.reference} - {self.amount} {self.currency}"

class Transaction(models.Model):
    TRANSACTION_TYPE = (
        ('payment', 'Payment'),
        ('refund', 'Refund'),
        ('transfer', 'Transfer'),
    )

    payment = models.ForeignKey(Payment, on_delete=models.CASCADE, related_name='transactions')
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    currency = models.CharField(max_length=3, default='NGN')
    transaction_type = models.CharField(max_length=20, choices=TRANSACTION_TYPE)
    reference = models.CharField(max_length=100, unique=True)
    status = models.CharField(max_length=20, choices=Payment.PAYMENT_STATUS, default='pending')
    payment_provider_reference = models.CharField(max_length=100, blank=True)
    metadata = models.JSONField(default=dict, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"Transaction {self.reference} - {self.amount} {self.currency}"

class Invoice(models.Model):
    payment = models.ForeignKey(Payment, on_delete=models.CASCADE, related_name='invoices')
    invoice_number = models.CharField(max_length=50, unique=True)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    currency = models.CharField(max_length=3, default='NGN')
    tax_amount = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    total_amount = models.DecimalField(max_digits=10, decimal_places=2)
    items = models.JSONField(default=list)
    customer_details = models.JSONField(default=dict)
    created_at = models.DateTimeField(auto_now_add=True)
    due_date = models.DateTimeField()
    is_paid = models.BooleanField(default=False)
    paid_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"Invoice {self.invoice_number} - {self.total_amount} {self.currency}" 