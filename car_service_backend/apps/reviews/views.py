from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.utils import timezone
from .models import Review, ReviewResponse, ReviewReport
from .serializers import (
    ReviewSerializer, ReviewCreateSerializer, ReviewResponseSerializer,
    ReviewResponseCreateSerializer, ReviewReportSerializer, ReviewReportCreateSerializer
)

class ReviewViewSet(viewsets.ModelViewSet):
    serializer_class = ReviewSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.role == 'admin':
            return Review.objects.all()
        elif user.role == 'mechanic':
            return Review.objects.filter(mechanic=user)
        return Review.objects.filter(customer=user)

    def get_serializer_class(self):
        if self.action == 'create':
            return ReviewCreateSerializer
        elif self.action == 'respond':
            return ReviewResponseCreateSerializer
        elif self.action == 'report':
            return ReviewReportCreateSerializer
        return ReviewSerializer

    def perform_create(self, serializer):
        serializer.save()

    @action(detail=True, methods=['post'])
    def respond(self, request, pk=None):
        """Add a response to a review"""
        review = self.get_object()
        if review.mechanic != request.user:
            return Response(
                {'error': 'Only the mechanic can respond to this review'},
                status=status.HTTP_403_FORBIDDEN
            )

        if hasattr(review, 'response'):
            return Response(
                {'error': 'This review already has a response'},
                status=status.HTTP_400_BAD_REQUEST
            )

        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save(review=review)
        return Response(ReviewResponseSerializer(review.response).data)

    @action(detail=True, methods=['post'])
    def report(self, request, pk=None):
        """Report a review"""
        review = self.get_object()
        if review.customer == request.user:
            return Response(
                {'error': 'You cannot report your own review'},
                status=status.HTTP_400_BAD_REQUEST
            )

        if review.reports.filter(reporter=request.user).exists():
            return Response(
                {'error': 'You have already reported this review'},
                status=status.HTTP_400_BAD_REQUEST
            )

        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save(review=review)
        return Response(ReviewReportSerializer(serializer.instance).data)

    @action(detail=True, methods=['post'])
    def verify(self, request, pk=None):
        """Verify a review (admin only)"""
        if request.user.role != 'admin':
            return Response(
                {'error': 'Only admins can verify reviews'},
                status=status.HTTP_403_FORBIDDEN
            )

        review = self.get_object()
        review.is_verified = True
        review.save()
        return Response(ReviewSerializer(review).data)

class ReviewReportViewSet(viewsets.ModelViewSet):
    serializer_class = ReviewReportSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.role == 'admin':
            return ReviewReport.objects.all()
        return ReviewReport.objects.filter(reporter=user)

    @action(detail=True, methods=['post'])
    def resolve(self, request, pk=None):
        """Resolve a report (admin only)"""
        if request.user.role != 'admin':
            return Response(
                {'error': 'Only admins can resolve reports'},
                status=status.HTTP_403_FORBIDDEN
            )

        report = self.get_object()
        if report.is_resolved:
            return Response(
                {'error': 'This report is already resolved'},
                status=status.HTTP_400_BAD_REQUEST
            )

        report.is_resolved = True
        report.resolved_at = timezone.now()
        report.resolved_by = request.user
        report.save()
        return Response(ReviewReportSerializer(report).data) 