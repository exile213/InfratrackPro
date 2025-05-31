from django.shortcuts import render
from django.contrib.auth.decorators import login_required
from django.contrib.admin.views.decorators import staff_member_required
from django.http import JsonResponse # Add this import
from geopy.geocoders import Nominatim # Ensure this import is at the top

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

def geocode(request):
    query = request.GET.get('query')

    if not query:
        return JsonResponse({'error': 'Query parameter is required.'}, status=400)

    try:
        geolocator = Nominatim(user_agent="public-infra-reporting-app")
        location = geolocator.geocode(query)

        if location:
            address_data = {
                'latitude': location.latitude,
                'longitude': location.longitude,
                'display_name': location.address,
                'address': {
                    'road': location.raw.get('address', {}).get('road', ''),
                    'city': location.raw.get('address', {}).get('city', location.raw.get('address', {}).get('town', location.raw.get('address', {}).get('municipality', location.raw.get('address', {}).get('city_district', '')))),
                    'suburb': location.raw.get('address', {}).get('suburb', location.raw.get('address', {}).get('village', location.raw.get('address', {}).get('hamlet', ''))),
                    'state': location.raw.get('address', {}).get('state', location.raw.get('address', {}).get('county', location.raw.get('address', {}).get('state_district', ''))),
                }
            }
            return JsonResponse(address_data)
        else:
            return JsonResponse({'error': 'Location not found.'}, status=404)
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)


"""GEOCODING  VIEWS"""
# Modified reverse_geocode to be a Django view
def reverse_geocode(request):
    lat = request.GET.get('lat')
    lon = request.GET.get('lon')

    if not lat or not lon:
        return JsonResponse({'error': 'Latitude and longitude are required.'}, status=400)

    try:
        geolocator = Nominatim(user_agent="public-infra-reporting-app")
        location = geolocator.reverse((lat, lon), exactly_one=True)

        if location:
            # Extract relevant address components
            address_data = {
                'display_name': location.address,
                'address': {
                    'road': location.raw.get('address', {}).get('road', ''),
                    'city': location.raw.get('address', {}).get('city', location.raw.get('address', {}).get('town', location.raw.get('address', {}).get('municipality', location.raw.get('address', {}).get('city_district', '')))),
                    'suburb': location.raw.get('address', {}).get('suburb', location.raw.get('address', {}).get('village', location.raw.get('address', {}).get('hamlet', ''))),
                    'state': location.raw.get('address', {}).get('state', location.raw.get('address', {}).get('county', location.raw.get('address', {}).get('state_district', ''))),
                }
            }
            return JsonResponse(address_data)
        else:
            return JsonResponse({'error': 'Address not found for the given coordinates.'}, status=404)
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)