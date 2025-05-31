from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required
from django.contrib.admin.views.decorators import staff_member_required
from django.http import JsonResponse # Add this import
from geopy.geocoders import Nominatim # Ensure this import is at the top
from django.contrib import messages
from django.contrib.auth import authenticate, login
from .models import Users, Report, Agency, IssueType, RoadType
from django.core.files.storage import default_storage
from django.core.files.base import ContentFile
import uuid
from datetime import datetime

def home(request):
    """Home page view"""
    return render(request, 'frontend/home.html')

def login_view(request):
    if request.method == 'POST':
        email = request.POST.get('email')
        password = request.POST.get('password')
        
        try:
            # Find user by email
            user = Users.objects.get(email=email)
            
            # Check password (in a real app, you'd use proper password hashing)
            if user.password == password:  # Note: In production, use proper password hashing!
                # Set session
                request.session['user_id'] = user.id
                request.session['username'] = user.username
                request.session['role'] = user.role_user.name
                
                messages.success(request, 'Login successful!')
                return redirect('frontend:dashboard')  # Updated to include namespace
            else:
                messages.error(request, 'Invalid password!')
        except Users.DoesNotExist:
            messages.error(request, 'No account found with this email!')
        
        return render(request, 'frontend/login.html')
    
    return render(request, 'frontend/login.html')

def register_agency(request):
    """Agency registration page view"""
    return render(request, 'frontend/register_agency.html')

@login_required
def dashboard(request):
    # Check if user is logged in
    if 'user_id' not in request.session:
        messages.error(request, 'Please login first!')
        return redirect('login')
    
    # Get user data
    user = Users.objects.get(id=request.session['user_id'])
    
    # Get filter parameters
    issue_type = request.GET.get('issue_type', 'All Types')
    status = request.GET.get('status', 'All Status')
    
    # Get reports for the user's agency
    reports = Report.objects.filter(assigned_agency=user.agency).order_by('-created_at')
    
    # Apply filters if specified
    if issue_type != 'All Types':
        reports = reports.filter(issue_type__name=issue_type)
    if status != 'All Status':
        reports = reports.filter(status_report_status=status)
    
    # Get all issue types and statuses for the filter dropdowns
    issue_types = IssueType.objects.all()
    statuses = Report.objects.values_list('status_report_status', flat=True).distinct()
    
    context = {
        'user': user,
        'role': request.session['role'],
        'reports': reports,
        'issue_types': issue_types,
        'statuses': statuses,
        'selected_issue_type': issue_type,
        'selected_status': status
    }
    return render(request, 'frontend/dashboard.html', context)

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

def logout_view(request):
    # Clear the session
    request.session.flush()
    messages.success(request, 'You have been successfully logged out.')
    return redirect('frontend:login')

def submit_report(request):
    if request.method == 'POST':
        try:
            # Generate tracking code
            tracking_code = f"REP-{datetime.now().strftime('%Y%m%d')}-{str(uuid.uuid4())[:8]}"
            
            # Handle file upload
            photo = request.FILES.get('photo')
            if not photo:
                return JsonResponse({'error': 'Photo is required'}, status=400)

            try:
                # Save the file
                path = default_storage.save(f'reports/{tracking_code}_{photo.name}', ContentFile(photo.read()))
                photo_url = default_storage.url(path)
            except Exception as e:
                print(f"Error saving photo: {str(e)}")
                return JsonResponse({'error': f'Error saving photo: {str(e)}'}, status=400)

            # Get required data
            try:
                default_agency = Agency.objects.select_for_update().first()
                if not default_agency:
                    return JsonResponse({'error': 'No agency available'}, status=400)

                issue_type = IssueType.objects.select_for_update().get(name=request.POST.get('issue_type'))
                road_type = RoadType.objects.select_for_update().get(name='Asphalt')
            except (Agency.DoesNotExist, IssueType.DoesNotExist, RoadType.DoesNotExist) as e:
                print(f"Database object not found: {str(e)}")
                return JsonResponse({'error': 'Required data not found in database'}, status=400)
            except Exception as e:
                print(f"Error accessing database: {str(e)}")
                return JsonResponse({'error': 'Database error'}, status=500)

            # Create the report
            try:
                report = Report.objects.create(
                    tracking_code=tracking_code,
                    description=request.POST.get('description'),
                    photo_url=photo_url,
                    latitude=request.POST.get('latitude'),
                    longitude=request.POST.get('longitude'),
                    address=request.POST.get('address'),
                    road_name=request.POST.get('road_name'),
                    assigned_agency=default_agency,
                    status_report_status='Pending',
                    citizen_name=request.POST.get('full_name'),
                    citizen_email=request.POST.get('email'),
                    issue_type=issue_type,
                    road_type=road_type
                )
            except Exception as e:
                print(f"Error creating report: {str(e)}")
                # Clean up the uploaded file if report creation fails
                try:
                    default_storage.delete(path)
                except:
                    pass
                return JsonResponse({'error': f'Error creating report: {str(e)}'}, status=400)

            return JsonResponse({
                'success': True,
                'tracking_code': tracking_code,
                'message': 'Report submitted successfully'
            })

        except Exception as e:
            print(f"Unexpected error in submit_report: {str(e)}")
            return JsonResponse({'error': str(e)}, status=500)

    return JsonResponse({'error': 'Method not allowed'}, status=405)