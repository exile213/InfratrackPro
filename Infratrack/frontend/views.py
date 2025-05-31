from django.shortcuts import render
from django.contrib.auth.decorators import login_required
from django.contrib.admin.views.decorators import staff_member_required

def home(request):
    """Home page view"""
    return render(request, 'frontend/home.html')

def login(request):
    """Login page view"""
    return render(request, 'frontend/login.html')

def register_agency(request):
    """Agency registration page view"""
    return render(request, 'frontend/register_agency.html')

@login_required
def dashboard(request):
    """Dashboard view for authenticated users"""
    return render(request, 'frontend/dashboard.html')

@login_required
def analytics(request):
    """Analytics view for authenticated users"""
    return render(request, 'frontend/analytics.html')

@login_required
def projects(request):
    """Projects management view"""
    return render(request, 'frontend/projects.html')

@login_required
def resources(request):
    """Resources management view"""
    return render(request, 'frontend/resources.html')

@login_required
def reports(request):
    """Reports view"""
    return render(request, 'frontend/reports.html')

@login_required
def profile(request):
    """User profile view"""
    return render(request, 'frontend/profile.html')

@staff_member_required
def admin_interface(request):
    """Admin interface view for staff members"""
    return render(request, 'frontend/admin.html')

def not_found(request):
    """404 Not Found page"""
    return render(request, 'frontend/404.html', status=404)
