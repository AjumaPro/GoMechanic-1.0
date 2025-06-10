from rest_framework import serializers
from .models import Payment, Transaction, Invoice
from apps.bookings.serializers import BookingSerializer

class TransactionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Transaction
        fields = ('id', 'payment', 'amount', 'currency', 'transaction_type',
                 'reference', 'status', 'payment_provider_reference',
                 'metadata', 'created_at')
        read_only_fields = ('id', 'reference', 'created_at')

class InvoiceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Invoice
        fields = ('id', 'payment', 'invoice_number', 'amount', 'currency',
                 'tax_amount', 'total_amount', 'items', 'customer_details',
                 'created_at', 'due_date', 'is_paid', 'paid_at')
        read_only_fields = ('id', 'invoice_number', 'created_at', 'is_paid', 'paid_at')

class PaymentSerializer(serializers.ModelSerializer):
    booking = BookingSerializer(read_only=True)
    transactions = TransactionSerializer(many=True, read_only=True)
    invoices = InvoiceSerializer(many=True, read_only=True)

    class Meta:
        model = Payment
        fields = ('id', 'booking', 'amount', 'currency', 'payment_method',
                 'status', 'reference', 'payment_provider',
                 'payment_provider_reference', 'metadata', 'transactions',
                 'invoices', 'created_at', 'updated_at')
        read_only_fields = ('id', 'reference', 'created_at', 'updated_at')

class PaymentCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Payment
        fields = ('booking', 'amount', 'currency', 'payment_method',
                 'payment_provider')

class PaymentUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Payment
        fields = ('status', 'payment_provider_reference', 'metadata')
        read_only_fields = ('status',)

class PaymentVerificationSerializer(serializers.Serializer):
    reference = serializers.CharField(max_length=100)
    payment_provider = serializers.CharField(max_length=50) 