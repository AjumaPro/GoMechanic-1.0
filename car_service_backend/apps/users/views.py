from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.contrib.auth import get_user_model
from .models import MechanicProfile
from .serializers import UserSerializer, UserRegistrationSerializer, MechanicProfileSerializer

User = get_user_model()

class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_serializer_class(self):
        if self.action == 'create':
            return UserRegistrationSerializer
        return UserSerializer

    def get_permissions(self):
        if self.action == 'create':
            return [permissions.AllowAny()]
        return super().get_permissions()

    @action(detail=False, methods=['get'])
    def me(self, request):
        serializer = self.get_serializer(request.user)
        return Response(serializer.data)

    @action(detail=False, methods=['get'])
    def mechanics(self, request):
        mechanics = User.objects.filter(user_type='mechanic')
        serializer = self.get_serializer(mechanics, many=True)
        return Response(serializer.data)

class MechanicProfileViewSet(viewsets.ModelViewSet):
    queryset = MechanicProfile.objects.all()
    serializer_class = MechanicProfileSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_permissions(self):
        if self.action in ['list', 'retrieve']:
            return [permissions.IsAuthenticated()]
        return [permissions.IsAdminUser()]

    @action(detail=False, methods=['get'])
    def available(self, request):
        available_mechanics = MechanicProfile.objects.filter(is_available=True)
        serializer = self.get_serializer(available_mechanics, many=True)
        return Response(serializer.data)

    @action(detail=True, methods=['post'])
    def update_availability(self, request, pk=None):
        mechanic = self.get_object()
        is_available = request.data.get('is_available', None)
        if is_available is not None:
            mechanic.is_available = is_available
            mechanic.save()
            return Response({'status': 'availability updated'})
        return Response({'error': 'is_available field is required'}, 
                       status=status.HTTP_400_BAD_REQUEST) 