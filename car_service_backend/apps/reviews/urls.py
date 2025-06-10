from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import ReviewViewSet, ReviewReportViewSet

router = DefaultRouter()
router.register(r'reviews', ReviewViewSet, basename='review')
router.register(r'reports', ReviewReportViewSet, basename='report')

urlpatterns = [
    path('', include(router.urls)),
] 