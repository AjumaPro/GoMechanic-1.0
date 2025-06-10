from django.urls import path
from . import views

app_name = 'dashboard'

urlpatterns = [
    path('', views.dashboard, name='dashboard'),
    path('login/', views.login_view, name='login'),
    path('logout/', views.logout_view, name='logout'),
    path('customers/', views.customers, name='customers'),
    path('register/', views.register_view, name='register'),
    path('vehicles/', views.vehicles, name='vehicles'),
    path('vehicles/<int:pk>/edit/', views.edit_vehicle, name='edit_vehicle'),
    path('vehicles/<int:pk>/delete/', views.delete_vehicle, name='delete_vehicle'),
    path('services/', views.services, name='services'),
    path('services/<int:pk>/edit/', views.edit_service, name='edit_service'),
    path('services/<int:pk>/delete/', views.delete_service, name='delete_service'),
    path('appointments/', views.appointments, name='appointments'),
    path('appointments/<int:pk>/edit/', views.edit_appointment, name='edit_appointment'),
    path('appointments/<int:pk>/delete/', views.delete_appointment, name='delete_appointment'),
    path('settings/', views.settings, name='settings'),
    path('api/vehicles/', views.get_vehicles_for_customer, name='get_vehicles_for_customer'),
    path('api/appointments/', views.get_appointments_for_calendar, name='get_appointments_for_calendar'),
] 