from rest_framework import serializers
from .models import Booking, BookingStatus, MechanicLocation
from apps.users.serializers import UserSerializer
from apps.vehicles.serializers import VehicleSerializer

class MechanicLocationSerializer(serializers.ModelSerializer):
    mechanic = UserSerializer(read_only=True)

    class Meta:
        model = MechanicLocation
        fields = ('id', 'mechanic', 'latitude', 'longitude', 'timestamp')
        read_only_fields = ('id', 'timestamp')

class BookingStatusSerializer(serializers.ModelSerializer):
    created_by = UserSerializer(read_only=True)

    class Meta:
        model = BookingStatus
        fields = ('id', 'status', 'notes', 'created_by', 'created_at')
        read_only_fields = ('id', 'created_at')

class BookingSerializer(serializers.ModelSerializer):
    customer = UserSerializer(read_only=True)
    mechanic = UserSerializer(read_only=True)
    vehicle = VehicleSerializer(read_only=True)
    status_updates = BookingStatusSerializer(many=True, read_only=True)
    mechanic_locations = MechanicLocationSerializer(many=True, read_only=True)

    class Meta:
        model = Booking
        fields = ('id', 'customer', 'vehicle', 'mechanic', 'service_type',
                 'description', 'status', 'scheduled_date', 'location',
                 'latitude', 'longitude', 'estimated_cost', 'actual_cost',
                 'is_paid', 'status_updates', 'mechanic_locations',
                 'created_at', 'updated_at')
        read_only_fields = ('id', 'customer', 'mechanic', 'status', 'actual_cost',
                          'is_paid', 'created_at', 'updated_at')

    def create(self, validated_data):
        validated_data['customer'] = self.context['request'].user
        return super().create(validated_data)

class BookingCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Booking
        fields = ('vehicle', 'service_type', 'description', 'scheduled_date',
                 'location', 'latitude', 'longitude', 'estimated_cost')

class BookingUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Booking
        fields = ('status', 'actual_cost', 'is_paid')
        read_only_fields = ('status',)

class MechanicLocationUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = MechanicLocation
        fields = ('latitude', 'longitude') 