from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import BookingViewSet, BookingStatusViewSet

router = DefaultRouter()
router.register(r'bookings', BookingViewSet)
router.register(r'status', BookingStatusViewSet)

urlpatterns = [
    path('', include(router.urls)),
] 