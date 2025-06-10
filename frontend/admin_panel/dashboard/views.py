from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth.decorators import login_required
from django.contrib.auth import authenticate, login, logout
from django.contrib import messages
from django.contrib.auth.forms import UserCreationForm
from django.http import JsonResponse
from django.core.paginator import Paginator
from .models import Vehicle, Service, Appointment
from .forms import VehicleForm, ServiceForm, AppointmentForm
from django.contrib.auth.models import User
from datetime import datetime, date

def login_view(request):
    """
    View for user login
    """
    if request.user.is_authenticated:
        return redirect('dashboard:dashboard')
        
    if request.method == 'POST':
        username = request.POST.get('username')
        password = request.POST.get('password')
        user = authenticate(request, username=username, password=password)
        
        if user is not None:
            login(request, user)
            messages.success(request, 'Successfully logged in!')
            return redirect('dashboard:dashboard')
        else:
            messages.error(request, 'Invalid username or password.')
    
    return render(request, 'dashboard/login.html')

@login_required
def logout_view(request):
    """
    View for user logout
    """
    logout(request)
    messages.success(request, 'Successfully logged out!')
    return redirect('dashboard:login')

@login_required
def dashboard(request):
    """
    View for the admin dashboard
    """
    return render(request, 'dashboard/index.html')

@login_required
def customers(request):
    """
    View for customer management
    """
    return render(request, 'dashboard/customers.html')

def register_view(request):
    """
    View for user registration
    """
    if request.user.is_authenticated:
        return redirect('dashboard:dashboard')
    if request.method == 'POST':
        form = UserCreationForm(request.POST)
        if form.is_valid():
            form.save()
            messages.success(request, 'Registration successful! You can now log in.')
            return redirect('dashboard:login')
    else:
        form = UserCreationForm()
    return render(request, 'dashboard/register.html', {'form': form})

@login_required
def vehicles(request):
    """
    View for vehicle management
    """
    search_query = request.GET.get('search', '')
    vehicles_list = Vehicle.objects.all()
    
    if search_query:
        vehicles_list = vehicles_list.filter(
            make_model__icontains=search_query) | \
            vehicles_list.filter(registration_number__icontains=search_query)
    
    paginator = Paginator(vehicles_list, 10)
    page = request.GET.get('page')
    vehicles = paginator.get_page(page)
    
    if request.method == 'POST':
        form = VehicleForm(request.POST)
        if form.is_valid():
            form.save()
            messages.success(request, 'Vehicle added successfully!')
            return redirect('dashboard:vehicles')
    else:
        form = VehicleForm()
    
    return render(request, 'dashboard/vehicles.html', {
        'vehicles': vehicles,
        'form': form,
        'users': User.objects.all()
    })

@login_required
def edit_vehicle(request, pk):
    vehicle = get_object_or_404(Vehicle, pk=pk)
    if request.method == 'POST':
        form = VehicleForm(request.POST, instance=vehicle)
        if form.is_valid():
            form.save()
            messages.success(request, 'Vehicle updated successfully!')
            return redirect('dashboard:vehicles')
    else:
        form = VehicleForm(instance=vehicle)
    return render(request, 'dashboard/edit_vehicle.html', {'form': form, 'vehicle': vehicle})

@login_required
def delete_vehicle(request, pk):
    vehicle = get_object_or_404(Vehicle, pk=pk)
    if request.method == 'POST':
        vehicle.delete()
        messages.success(request, 'Vehicle deleted successfully!')
        return redirect('dashboard:vehicles')
    return render(request, 'dashboard/delete_vehicle.html', {'vehicle': vehicle})

@login_required
def services(request):
    """
    View for service management
    """
    search_query = request.GET.get('search', '')
    services_list = Service.objects.all()
    
    if search_query:
        services_list = services_list.filter(name__icontains=search_query)
    
    paginator = Paginator(services_list, 10)
    page = request.GET.get('page')
    services = paginator.get_page(page)
    
    if request.method == 'POST':
        form = ServiceForm(request.POST)
        if form.is_valid():
            form.save()
            messages.success(request, 'Service added successfully!')
            return redirect('dashboard:services')
    else:
        form = ServiceForm()
    
    return render(request, 'dashboard/services.html', {
        'services': services,
        'form': form
    })

@login_required
def edit_service(request, pk):
    service = get_object_or_404(Service, pk=pk)
    if request.method == 'POST':
        form = ServiceForm(request.POST, instance=service)
        if form.is_valid():
            form.save()
            messages.success(request, 'Service updated successfully!')
            return redirect('dashboard:services')
    else:
        form = ServiceForm(instance=service)
    return render(request, 'dashboard/edit_service.html', {'form': form, 'service': service})

@login_required
def delete_service(request, pk):
    service = get_object_or_404(Service, pk=pk)
    if request.method == 'POST':
        service.delete()
        messages.success(request, 'Service deleted successfully!')
        return redirect('dashboard:services')
    return render(request, 'dashboard/delete_service.html', {'service': service})

@login_required
def appointments(request):
    """
    View for appointment management
    """
    today = date.today()
    today_appointments = Appointment.objects.filter(date=today).order_by('time')
    upcoming_appointments = Appointment.objects.filter(date__gt=today).order_by('date', 'time')
    
    if request.method == 'POST':
        form = AppointmentForm(request.POST)
        if form.is_valid():
            form.save()
            messages.success(request, 'Appointment scheduled successfully!')
            return redirect('dashboard:appointments')
    else:
        form = AppointmentForm()
    
    return render(request, 'dashboard/appointments.html', {
        'today_appointments': today_appointments,
        'upcoming_appointments': upcoming_appointments,
        'form': form,
        'users': User.objects.all(),
        'vehicles': Vehicle.objects.all(),
        'services': Service.objects.all()
    })

@login_required
def edit_appointment(request, pk):
    appointment = get_object_or_404(Appointment, pk=pk)
    if request.method == 'POST':
        form = AppointmentForm(request.POST, instance=appointment)
        if form.is_valid():
            form.save()
            messages.success(request, 'Appointment updated successfully!')
            return redirect('dashboard:appointments')
    else:
        form = AppointmentForm(instance=appointment)
    return render(request, 'dashboard/edit_appointment.html', {'form': form, 'appointment': appointment})

@login_required
def delete_appointment(request, pk):
    appointment = get_object_or_404(Appointment, pk=pk)
    if request.method == 'POST':
        appointment.delete()
        messages.success(request, 'Appointment cancelled successfully!')
        return redirect('dashboard:appointments')
    return render(request, 'dashboard/delete_appointment.html', {'appointment': appointment})

@login_required
def get_vehicles_for_customer(request):
    customer_id = request.GET.get('customer_id')
    vehicles = Vehicle.objects.filter(owner_id=customer_id).values('id', 'make_model', 'registration_number')
    return JsonResponse(list(vehicles), safe=False)

@login_required
def get_appointments_for_calendar(request):
    start = request.GET.get('start')
    end = request.GET.get('end')
    appointments = Appointment.objects.filter(
        date__range=[start, end]
    ).values('id', 'service__name', 'customer__username', 'date', 'time')
    
    events = []
    for apt in appointments:
        events.append({
            'id': apt['id'],
            'title': f"{apt['service__name']} - {apt['customer__username']}",
            'start': f"{apt['date']}T{apt['time']}",
            'end': f"{apt['date']}T{apt['time']}",  # You might want to add duration here
        })
    
    return JsonResponse(events, safe=False)

@login_required
def settings(request):
    """
    View for settings management
    """
    return render(request, 'dashboard/settings.html')
