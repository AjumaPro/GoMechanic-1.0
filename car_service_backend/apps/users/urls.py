from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import UserViewSet, MechanicProfileViewSet

router = DefaultRouter()
router.register(r'', UserViewSet)
router.register(r'mechanics', MechanicProfileViewSet)

urlpatterns = [
    path('', include(router.urls)),
] 