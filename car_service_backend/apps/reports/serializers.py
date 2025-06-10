from rest_framework import serializers

class BookingStatsSerializer(serializers.Serializer):
    total_bookings = serializers.IntegerField()
    completed_bookings = serializers.IntegerField()
    pending_bookings = serializers.IntegerField()
    cancelled_bookings = serializers.IntegerField()

class RevenueStatsSerializer(serializers.Serializer):
    total_revenue = serializers.DecimalField(max_digits=12, decimal_places=2)
    total_paid = serializers.DecimalField(max_digits=12, decimal_places=2)
    total_unpaid = serializers.DecimalField(max_digits=12, decimal_places=2)

class UserStatsSerializer(serializers.Serializer):
    total_customers = serializers.IntegerField()
    total_mechanics = serializers.IntegerField()
    active_customers = serializers.IntegerField()
    active_mechanics = serializers.IntegerField() 