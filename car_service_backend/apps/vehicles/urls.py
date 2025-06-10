from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import VehicleViewSet, ServiceHistoryViewSet

router = DefaultRouter()
router.register(r'vehicles', VehicleViewSet)
router.register(r'service-history', ServiceHistoryViewSet)

urlpatterns = [
    path('', include(router.urls)),
] 