from rest_framework import serializers
from .models import Review, ReviewResponse, ReviewReport
from apps.users.serializers import UserSerializer
from apps.bookings.serializers import BookingSerializer
from apps.vehicles.serializers import VehicleSerializer

class ReviewResponseSerializer(serializers.ModelSerializer):
    mechanic = UserSerializer(read_only=True)

    class Meta:
        model = ReviewResponse
        fields = ('id', 'mechanic', 'comment', 'created_at', 'updated_at')
        read_only_fields = ('id', 'created_at', 'updated_at')

class ReviewSerializer(serializers.ModelSerializer):
    customer = UserSerializer(read_only=True)
    mechanic = UserSerializer(read_only=True)
    vehicle = VehicleSerializer(read_only=True)
    booking = BookingSerializer(read_only=True)
    response = ReviewResponseSerializer(read_only=True)

    class Meta:
        model = Review
        fields = ('id', 'booking', 'customer', 'mechanic', 'vehicle',
                 'rating', 'comment', 'is_verified', 'response',
                 'created_at', 'updated_at')
        read_only_fields = ('id', 'is_verified', 'created_at', 'updated_at')

class ReviewCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Review
        fields = ('booking', 'rating', 'comment')

    def validate(self, data):
        booking = data['booking']
        if booking.status != 'completed':
            raise serializers.ValidationError(
                "Cannot review a booking that is not completed"
            )
        if hasattr(booking, 'review'):
            raise serializers.ValidationError(
                "This booking has already been reviewed"
            )
        return data

    def create(self, validated_data):
        booking = validated_data['booking']
        review = Review.objects.create(
            booking=booking,
            customer=booking.customer,
            mechanic=booking.mechanic,
            vehicle=booking.vehicle,
            rating=validated_data['rating'],
            comment=validated_data['comment']
        )
        return review

class ReviewResponseCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = ReviewResponse
        fields = ('comment',)

    def create(self, validated_data):
        review = self.context['review']
        response = ReviewResponse.objects.create(
            review=review,
            mechanic=review.mechanic,
            comment=validated_data['comment']
        )
        return response

class ReviewReportSerializer(serializers.ModelSerializer):
    reporter = UserSerializer(read_only=True)
    resolved_by = UserSerializer(read_only=True)

    class Meta:
        model = ReviewReport
        fields = ('id', 'review', 'reporter', 'report_type', 'description',
                 'is_resolved', 'resolved_at', 'resolved_by',
                 'created_at', 'updated_at')
        read_only_fields = ('id', 'reporter', 'is_resolved', 'resolved_at',
                          'resolved_by', 'created_at', 'updated_at')

class ReviewReportCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = ReviewReport
        fields = ('report_type', 'description')

    def create(self, validated_data):
        review = self.context['review']
        report = ReviewReport.objects.create(
            review=review,
            reporter=self.context['request'].user,
            report_type=validated_data['report_type'],
            description=validated_data['description']
        )
        return report 