from django.db import models
from django.conf import settings

class Vehicle(models.Model):
    VEHICLE_TYPES = (
        ('car', 'Car'),
        ('suv', 'SUV'),
        ('truck', 'Truck'),
        ('van', 'Van'),
        ('motorcycle', 'Motorcycle'),
    )

    FUEL_TYPES = (
        ('petrol', 'Petrol'),
        ('diesel', 'Diesel'),
        ('electric', 'Electric'),
        ('hybrid', 'Hybrid'),
        ('cng', 'CNG'),
    )

    owner = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='vehicles')
    vehicle_type = models.CharField(max_length=20, choices=VEHICLE_TYPES)
    make = models.CharField(max_length=50)
    model = models.CharField(max_length=50)
    year = models.PositiveIntegerField()
    registration_number = models.CharField(max_length=20, unique=True)
    fuel_type = models.CharField(max_length=20, choices=FUEL_TYPES)
    color = models.CharField(max_length=30)
    mileage = models.PositiveIntegerField(help_text='Current mileage in kilometers')
    last_service_date = models.DateField(null=True, blank=True)
    next_service_date = models.DateField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.make} {self.model} ({self.registration_number})"

class ServiceHistory(models.Model):
    vehicle = models.ForeignKey(Vehicle, on_delete=models.CASCADE, related_name='service_history')
    service_type = models.CharField(max_length=100)
    description = models.TextField()
    cost = models.DecimalField(max_digits=10, decimal_places=2)
    service_date = models.DateField()
    next_service_date = models.DateField(null=True, blank=True)
    mechanic = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, 
                               null=True, related_name='services_performed')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name_plural = 'Service Histories'
        ordering = ['-service_date']

    def __str__(self):
        return f"{self.vehicle} - {self.service_type} ({self.service_date})" 