from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.utils import timezone
from django.db.models import Q
from .models import Booking, BookingStatus, MechanicLocation
from .serializers import (
    BookingSerializer, BookingCreateSerializer, BookingUpdateSerializer,
    BookingStatusSerializer, MechanicLocationSerializer, MechanicLocationUpdateSerializer
)

class BookingViewSet(viewsets.ModelViewSet):
    serializer_class = BookingSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.user_type == 'mechanic':
            return Booking.objects.filter(mechanic=user)
        elif user.user_type == 'customer':
            return Booking.objects.filter(customer=user)
        return Booking.objects.all()

    def get_serializer_class(self):
        if self.action == 'create':
            return BookingCreateSerializer
        elif self.action in ['update', 'partial_update']:
            return BookingUpdateSerializer
        return BookingSerializer

    def perform_create(self, serializer):
        booking = serializer.save()
        # Create initial status update
        BookingStatus.objects.create(
            booking=booking,
            status='pending',
            created_by=self.request.user
        )

    @action(detail=True, methods=['post'])
    def assign_mechanic(self, request, pk=None):
        booking = self.get_object()
        mechanic_id = request.data.get('mechanic_id')
        
        if not mechanic_id:
            return Response({'error': 'mechanic_id is required'}, 
                          status=status.HTTP_400_BAD_REQUEST)
        
        try:
            booking.mechanic_id = mechanic_id
            booking.status = 'accepted'
            booking.save()
            
            # Create status update
            BookingStatus.objects.create(
                booking=booking,
                status='accepted',
                notes=f'Assigned to mechanic #{mechanic_id}',
                created_by=request.user
            )
            
            return Response(BookingSerializer(booking).data)
        except Exception as e:
            return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=True, methods=['post'])
    def update_status(self, request, pk=None):
        booking = self.get_object()
        new_status = request.data.get('status')
        notes = request.data.get('notes', '')
        
        if not new_status or new_status not in dict(Booking.STATUS_CHOICES):
            return Response({'error': 'Invalid status'}, 
                          status=status.HTTP_400_BAD_REQUEST)
        
        booking.status = new_status
        booking.save()
        
        # Create status update
        BookingStatus.objects.create(
            booking=booking,
            status=new_status,
            notes=notes,
            created_by=request.user
        )
        
        return Response(BookingSerializer(booking).data)

    @action(detail=True, methods=['post'])
    def update_location(self, request, pk=None):
        booking = self.get_object()
        if not booking.mechanic or booking.mechanic != request.user:
            return Response({'error': 'Not authorized'}, 
                          status=status.HTTP_403_FORBIDDEN)
        
        serializer = MechanicLocationUpdateSerializer(data=request.data)
        if serializer.is_valid():
            MechanicLocation.objects.create(
                booking=booking,
                mechanic=request.user,
                **serializer.validated_data
            )
            return Response({'status': 'location updated'})
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=False, methods=['get'])
    def available_jobs(self, request):
        if request.user.user_type != 'mechanic':
            return Response({'error': 'Only mechanics can view available jobs'}, 
                          status=status.HTTP_403_FORBIDDEN)
        
        available_bookings = Booking.objects.filter(
            status='pending',
            scheduled_date__gte=timezone.now()
        ).exclude(
            Q(mechanic=request.user) | 
            Q(customer=request.user)
        )
        
        serializer = self.get_serializer(available_bookings, many=True)
        return Response(serializer.data)

class BookingStatusViewSet(viewsets.ReadOnlyModelViewSet):
    serializer_class = BookingStatusSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.user_type == 'mechanic':
            return BookingStatus.objects.filter(booking__mechanic=user)
        elif user.user_type == 'customer':
            return BookingStatus.objects.filter(booking__customer=user)
        return BookingStatus.objects.all() 