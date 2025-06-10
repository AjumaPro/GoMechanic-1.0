from django.urls import path
from .views import BookingStatsView, RevenueStatsView, UserStatsView

urlpatterns = [
    path('bookings/', BookingStatsView.as_view(), name='booking-stats'),
    path('revenue/', RevenueStatsView.as_view(), name='revenue-stats'),
    path('users/', UserStatsView.as_view(), name='user-stats'),
] 