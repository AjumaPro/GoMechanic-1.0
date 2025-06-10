from rest_framework import serializers
from .models import Vehicle, ServiceHistory
from apps.users.serializers import UserSerializer

class ServiceHistorySerializer(serializers.ModelSerializer):
    mechanic = UserSerializer(read_only=True)

    class Meta:
        model = ServiceHistory
        fields = ('id', 'service_type', 'description', 'cost', 'service_date',
                 'next_service_date', 'mechanic', 'created_at', 'updated_at')
        read_only_fields = ('id', 'created_at', 'updated_at')

class VehicleSerializer(serializers.ModelSerializer):
    owner = UserSerializer(read_only=True)
    service_history = ServiceHistorySerializer(many=True, read_only=True)

    class Meta:
        model = Vehicle
        fields = ('id', 'owner', 'vehicle_type', 'make', 'model', 'year',
                 'registration_number', 'fuel_type', 'color', 'mileage',
                 'last_service_date', 'next_service_date', 'service_history',
                 'created_at', 'updated_at')
        read_only_fields = ('id', 'created_at', 'updated_at')

    def create(self, validated_data):
        validated_data['owner'] = self.context['request'].user
        return super().create(validated_data) 