from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAdminUser
from apps.bookings.models import Booking
from apps.payments.models import Payment
from apps.users.models import User
from .serializers import BookingStatsSerializer, RevenueStatsSerializer, UserStatsSerializer
from django.db.models import Sum, Count, Q

class BookingStatsView(APIView):
    permission_classes = [IsAdminUser]

    def get(self, request):
        total = Booking.objects.count()
        completed = Booking.objects.filter(status='completed').count()
        pending = Booking.objects.filter(status='pending').count()
        cancelled = Booking.objects.filter(status='cancelled').count()
        data = {
            'total_bookings': total,
            'completed_bookings': completed,
            'pending_bookings': pending,
            'cancelled_bookings': cancelled,
        }
        return Response(BookingStatsSerializer(data).data)

class RevenueStatsView(APIView):
    permission_classes = [IsAdminUser]

    def get(self, request):
        total = Payment.objects.aggregate(total=Sum('amount'))['total'] or 0
        paid = Payment.objects.filter(is_paid=True).aggregate(total=Sum('amount'))['total'] or 0
        unpaid = Payment.objects.filter(is_paid=False).aggregate(total=Sum('amount'))['total'] or 0
        data = {
            'total_revenue': total,
            'total_paid': paid,
            'total_unpaid': unpaid,
        }
        return Response(RevenueStatsSerializer(data).data)

class UserStatsView(APIView):
    permission_classes = [IsAdminUser]

    def get(self, request):
        total_customers = User.objects.filter(role='customer').count()
        total_mechanics = User.objects.filter(role='mechanic').count()
        active_customers = User.objects.filter(role='customer', is_active=True).count()
        active_mechanics = User.objects.filter(role='mechanic', is_active=True).count()
        data = {
            'total_customers': total_customers,
            'total_mechanics': total_mechanics,
            'active_customers': active_customers,
            'active_mechanics': active_mechanics,
        }
        return Response(UserStatsSerializer(data).data) 