from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.utils import timezone
from .models import Vehicle, ServiceHistory
from .serializers import VehicleSerializer, ServiceHistorySerializer

class VehicleViewSet(viewsets.ModelViewSet):
    serializer_class = VehicleSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.user_type == 'mechanic':
            return Vehicle.objects.all()
        return Vehicle.objects.filter(owner=user)

    @action(detail=True, methods=['post'])
    def add_service_history(self, request, pk=None):
        vehicle = self.get_object()
        serializer = ServiceHistorySerializer(data=request.data)
        
        if serializer.is_valid():
            serializer.save(
                vehicle=vehicle,
                mechanic=request.user
            )
            
            # Update vehicle's last service date
            vehicle.last_service_date = serializer.validated_data['service_date']
            vehicle.next_service_date = serializer.validated_data.get('next_service_date')
            vehicle.save()
            
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=False, methods=['get'])
    def due_for_service(self, request):
        today = timezone.now().date()
        vehicles = self.get_queryset().filter(
            next_service_date__lte=today
        )
        serializer = self.get_serializer(vehicles, many=True)
        return Response(serializer.data)

class ServiceHistoryViewSet(viewsets.ModelViewSet):
    serializer_class = ServiceHistorySerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.user_type == 'mechanic':
            return ServiceHistory.objects.filter(mechanic=user)
        return ServiceHistory.objects.filter(vehicle__owner=user)

    def perform_create(self, serializer):
        serializer.save(mechanic=self.request.user) 