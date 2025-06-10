from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.utils import timezone
from django.conf import settings
import uuid
import requests
from .models import Payment, Transaction, Invoice
from .serializers import (
    PaymentSerializer, PaymentCreateSerializer, PaymentUpdateSerializer,
    PaymentVerificationSerializer, TransactionSerializer, InvoiceSerializer
)

class PaymentViewSet(viewsets.ModelViewSet):
    serializer_class = PaymentSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.user_type == 'mechanic':
            return Payment.objects.filter(booking__mechanic=user)
        elif user.user_type == 'customer':
            return Payment.objects.filter(booking__customer=user)
        return Payment.objects.all()

    def get_serializer_class(self):
        if self.action == 'create':
            return PaymentCreateSerializer
        elif self.action in ['update', 'partial_update']:
            return PaymentUpdateSerializer
        return PaymentSerializer

    def perform_create(self, serializer):
        # Generate unique reference
        reference = f"PAY-{uuid.uuid4().hex[:10].upper()}"
        payment = serializer.save(reference=reference)
        
        # Initialize payment with provider
        self._initialize_payment(payment)

    def _initialize_payment(self, payment):
        """Initialize payment with the selected payment provider"""
        if payment.payment_provider == 'paystack':
            self._initialize_paystack_payment(payment)
        elif payment.payment_provider == 'flutterwave':
            self._initialize_flutterwave_payment(payment)

    def _initialize_paystack_payment(self, payment):
        """Initialize payment with Paystack"""
        url = "https://api.paystack.co/transaction/initialize"
        headers = {
            "Authorization": f"Bearer {settings.PAYSTACK_SECRET_KEY}",
            "Content-Type": "application/json"
        }
        data = {
            "amount": int(payment.amount * 100),  # Convert to kobo
            "email": payment.booking.customer.email,
            "reference": payment.reference,
            "callback_url": f"{settings.FRONTEND_URL}/payment/verify/{payment.reference}"
        }
        
        try:
            response = requests.post(url, headers=headers, json=data)
            response.raise_for_status()
            result = response.json()
            
            if result['status']:
                payment.payment_provider_reference = result['data']['reference']
                payment.metadata = result['data']
                payment.save()
                
                # Create transaction record
                Transaction.objects.create(
                    payment=payment,
                    amount=payment.amount,
                    currency=payment.currency,
                    transaction_type='payment',
                    reference=f"TRX-{uuid.uuid4().hex[:10].upper()}",
                    payment_provider_reference=payment.payment_provider_reference
                )
        except Exception as e:
            payment.status = 'failed'
            payment.metadata = {'error': str(e)}
            payment.save()

    def _initialize_flutterwave_payment(self, payment):
        """Initialize payment with Flutterwave"""
        url = "https://api.flutterwave.com/v3/payments"
        headers = {
            "Authorization": f"Bearer {settings.FLUTTERWAVE_SECRET_KEY}",
            "Content-Type": "application/json"
        }
        data = {
            "amount": payment.amount,
            "currency": payment.currency,
            "payment_options": "card,banktransfer,ussd",
            "redirect_url": f"{settings.FRONTEND_URL}/payment/verify/{payment.reference}",
            "customer": {
                "email": payment.booking.customer.email,
                "name": payment.booking.customer.get_full_name()
            },
            "customizations": {
                "title": "Car Service Payment",
                "description": f"Payment for booking #{payment.booking.id}"
            },
            "tx_ref": payment.reference
        }
        
        try:
            response = requests.post(url, headers=headers, json=data)
            response.raise_for_status()
            result = response.json()
            
            if result['status'] == 'success':
                payment.payment_provider_reference = result['data']['reference']
                payment.metadata = result['data']
                payment.save()
                
                # Create transaction record
                Transaction.objects.create(
                    payment=payment,
                    amount=payment.amount,
                    currency=payment.currency,
                    transaction_type='payment',
                    reference=f"TRX-{uuid.uuid4().hex[:10].upper()}",
                    payment_provider_reference=payment.payment_provider_reference
                )
        except Exception as e:
            payment.status = 'failed'
            payment.metadata = {'error': str(e)}
            payment.save()

    @action(detail=True, methods=['post'])
    def verify(self, request, pk=None):
        payment = self.get_object()
        serializer = PaymentVerificationSerializer(data=request.data)
        
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
        if payment.payment_provider == 'paystack':
            return self._verify_paystack_payment(payment)
        elif payment.payment_provider == 'flutterwave':
            return self._verify_flutterwave_payment(payment)
        
        return Response({'error': 'Invalid payment provider'}, 
                       status=status.HTTP_400_BAD_REQUEST)

    def _verify_paystack_payment(self, payment):
        """Verify payment with Paystack"""
        url = f"https://api.paystack.co/transaction/verify/{payment.reference}"
        headers = {
            "Authorization": f"Bearer {settings.PAYSTACK_SECRET_KEY}"
        }
        
        try:
            response = requests.get(url, headers=headers)
            response.raise_for_status()
            result = response.json()
            
            if result['status'] and result['data']['status'] == 'success':
                payment.status = 'completed'
                payment.metadata.update(result['data'])
                payment.save()
                
                # Update booking payment status
                payment.booking.is_paid = True
                payment.booking.save()
                
                # Create invoice
                self._create_invoice(payment)
                
                return Response(PaymentSerializer(payment).data)
            
            return Response({'error': 'Payment verification failed'}, 
                          status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            return Response({'error': str(e)}, 
                          status=status.HTTP_400_BAD_REQUEST)

    def _verify_flutterwave_payment(self, payment):
        """Verify payment with Flutterwave"""
        url = f"https://api.flutterwave.com/v3/transactions/{payment.reference}/verify"
        headers = {
            "Authorization": f"Bearer {settings.FLUTTERWAVE_SECRET_KEY}"
        }
        
        try:
            response = requests.get(url, headers=headers)
            response.raise_for_status()
            result = response.json()
            
            if result['status'] == 'success' and result['data']['status'] == 'successful':
                payment.status = 'completed'
                payment.metadata.update(result['data'])
                payment.save()
                
                # Update booking payment status
                payment.booking.is_paid = True
                payment.booking.save()
                
                # Create invoice
                self._create_invoice(payment)
                
                return Response(PaymentSerializer(payment).data)
            
            return Response({'error': 'Payment verification failed'}, 
                          status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            return Response({'error': str(e)}, 
                          status=status.HTTP_400_BAD_REQUEST)

    def _create_invoice(self, payment):
        """Create invoice for completed payment"""
        booking = payment.booking
        invoice_number = f"INV-{uuid.uuid4().hex[:10].upper()}"
        
        # Calculate tax (assuming 7.5% VAT)
        tax_rate = 0.075
        tax_amount = payment.amount * tax_rate
        total_amount = payment.amount + tax_amount
        
        # Create invoice
        Invoice.objects.create(
            payment=payment,
            invoice_number=invoice_number,
            amount=payment.amount,
            currency=payment.currency,
            tax_amount=tax_amount,
            total_amount=total_amount,
            items=[{
                'description': f"{booking.service_type} service",
                'quantity': 1,
                'unit_price': payment.amount,
                'total': payment.amount
            }],
            customer_details={
                'name': booking.customer.get_full_name(),
                'email': booking.customer.email,
                'phone': booking.customer.phone_number
            },
            due_date=timezone.now() + timezone.timedelta(days=30),
            is_paid=True,
            paid_at=timezone.now()
        )

class TransactionViewSet(viewsets.ReadOnlyModelViewSet):
    serializer_class = TransactionSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.user_type == 'mechanic':
            return Transaction.objects.filter(payment__booking__mechanic=user)
        elif user.user_type == 'customer':
            return Transaction.objects.filter(payment__booking__customer=user)
        return Transaction.objects.all()

class InvoiceViewSet(viewsets.ReadOnlyModelViewSet):
    serializer_class = InvoiceSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.user_type == 'mechanic':
            return Invoice.objects.filter(payment__booking__mechanic=user)
        elif user.user_type == 'customer':
            return Invoice.objects.filter(payment__booking__customer=user)
        return Invoice.objects.all() 