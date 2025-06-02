from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required
from django.contrib.admin.views.decorators import staff_member_required
from django.http import JsonResponse # Add this import
from geopy.geocoders import Nominatim # Ensure this import is at the top
from django.contrib import messages
from django.contrib.auth import authenticate, login
from .models import Users, Report, Agency, IssueType, RoadType, RoadTypeAgencyMapping
from django.core.files.storage import default_storage
from django.core.files.base import ContentFile
import uuid
from datetime import datetime, date as dt_date
from django.views.decorators.http import require_GET
from django.utils.dateparse import parse_date
from django.db.models import Count, Q
import requests  # Add this import for Overpass API
import time
from django.core.paginator import Paginator
from django.db.models.functions import TruncMonth, TruncYear
import os
import csv
from django.conf import settings

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

def login_required_custom(view_func):
    def wrapper(request, *args, **kwargs):
        if 'user_id' not in request.session:
            messages.error(request, 'Please login first!')
            return redirect('frontend:login')
        return view_func(request, *args, **kwargs)
    return wrapper

@login_required_custom
def dashboard(request):
    # Get user data
    user = Users.objects.get(id=request.session['user_id'])
    
    # Get filter parameters with default values
    issue_type = request.GET.get('issue_type', 'All Types')
    status = request.GET.get('status', 'All Status')
    start_date = request.GET.get('start_date', '')
    end_date = request.GET.get('end_date', '')
    
    # Get reports for the user's agency
    reports = Report.objects.filter(assigned_agency=user.agency).order_by('-created_at')
    
    # Apply filters if specified
    if issue_type and issue_type != 'All Types':
        reports = reports.filter(issue_type__name=issue_type)
    
    if status and status != 'All Status':
        reports = reports.filter(status_report_status=status)
    
    if start_date:
        try:
            start_date = datetime.strptime(start_date, '%Y-%m-%d')
            reports = reports.filter(created_at__gte=start_date)
        except ValueError:
            pass
    
    if end_date:
        try:
            end_date = datetime.strptime(end_date, '%Y-%m-%d')
            reports = reports.filter(created_at__lte=end_date)
        except ValueError:
            pass
    
    # Paginate reports (5 per page)
    paginator = Paginator(reports, 5)
    page_number = request.GET.get('page')
    page_obj = paginator.get_page(page_number)
    
    # Get all issue types and statuses for the filter dropdowns
    issue_types = IssueType.objects.all()
    statuses = Report.objects.values_list('status_report_status', flat=True).distinct()
    
    context = {
        'user': user,
        'role': request.session['role'],
        'reports': page_obj,  # Use paginated object
        'issue_types': issue_types,
        'statuses': statuses,
        'selected_issue_type': issue_type,
        'selected_status': status,
        'selected_start_date': start_date if isinstance(start_date, str) else start_date.strftime('%Y-%m-%d') if start_date else '',
        'selected_end_date': end_date if isinstance(end_date, str) else end_date.strftime('%Y-%m-%d') if end_date else ''
    }
    
    return render(request, 'frontend/dashboard.html', context)

@login_required_custom
def analytics(request):
    """Analytics view for authenticated users"""
    return render(request, 'frontend/analytics.html')

@login_required_custom
def projects(request):
    """Projects management view"""
    return render(request, 'frontend/projects.html')

@login_required_custom
def resources(request):
    """Resources management view"""
    return render(request, 'frontend/resources.html')

@login_required_custom
def reports(request):
    """Reports view"""
    return render(request, 'frontend/reports.html')

@login_required_custom
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
        # Convert string coordinates to float
        lat = float(lat)
        lon = float(lon)
        
        # Use a more specific user agent
        geolocator = Nominatim(
            user_agent="InfraTrack/1.0 (https://github.com/yourusername/infratrack; your@email.com) Python/3.x"
        )
        
        # Add a small delay to respect rate limits
        time.sleep(1)
        
        location = geolocator.reverse((lat, lon), exactly_one=True)

        if location:
            # Extract relevant address components
            address_data = {
                'display_name': location.address,
                'address': {
                    'road': location.raw.get('address', {}).get('road', ''),
                    'city': location.raw.get('address', {}).get('city', 
                            location.raw.get('address', {}).get('town', 
                            location.raw.get('address', {}).get('municipality', 
                            location.raw.get('address', {}).get('city_district', '')))),
                    'suburb': location.raw.get('address', {}).get('suburb', 
                             location.raw.get('address', {}).get('village', 
                             location.raw.get('address', {}).get('hamlet', ''))),
                    'state': location.raw.get('address', {}).get('state', 
                            location.raw.get('address', {}).get('county', 
                            location.raw.get('address', {}).get('state_district', ''))),
                }
            }
            return JsonResponse(address_data)
        else:
            return JsonResponse({
                'error': 'Address not found for the given coordinates.',
                'coordinates': {'lat': lat, 'lon': lon}
            }, status=404)
    except ValueError as e:
        return JsonResponse({
            'error': 'Invalid coordinates format.',
            'details': str(e),
            'received': {'lat': lat, 'lon': lon}
        }, status=400)
    except Exception as e:
        print(f"Error in reverse_geocode: {str(e)}")  # Add server-side logging
        return JsonResponse({
            'error': 'An error occurred while processing your request.',
            'details': str(e),
            'coordinates': {'lat': lat, 'lon': lon}
        }, status=500)

def logout_view(request):
    # Clear the session
    request.session.flush()
    messages.success(request, 'You have been successfully logged out.')
    return redirect('frontend:login')

def classify_road_and_assign_agency(lat, lon, city=None):
    """
    Classifies the road type at the given lat/lon using Overpass API and assigns the correct agency.
    Returns (agency, road_type_str, road_name)
    """
    from .models import RoadTypeAgencyMapping
    
    overpass_url = "https://overpass-api.de/api/interpreter"
    query = f"""
    [out:json];
    way(around:20,{lat},{lon})["highway"];
    out tags center 1;
    """
    try:
        response = requests.post(overpass_url, data={'data': query}, timeout=10)
        data = response.json()
        if data['elements']:
            way = data['elements'][0]
            highway_type = way['tags'].get('highway')
            road_name = way['tags'].get('name', '')
            
            # Determine jurisdiction type based on highway type
            # National roads take precedence regardless of location
            if highway_type in ['motorway', 'trunk', 'primary', 'secondary']:
                jurisdiction_type = 'national'
                # For national roads, always use DPWH regardless of city
                dpwh_agency = Agency.objects.filter(name__icontains="DPWH").first()
                if dpwh_agency:
                    # Get the exact road type from our database
                    road_type = RoadType.objects.filter(name=highway_type).first()
                    if not road_type:
                        # If exact match not found, try to find a similar type
                        if highway_type == 'motorway':
                            road_type = RoadType.objects.filter(name__icontains='highway').first()
                        elif highway_type == 'trunk':
                            road_type = RoadType.objects.filter(name__icontains='major').first()
                        elif highway_type in ['primary', 'secondary']:
                            road_type = RoadType.objects.filter(name__icontains='arterial').first()
                    
                    if not road_type:
                        road_type = RoadType.objects.first()  # Fallback to first road type
                    
                    return dpwh_agency, highway_type, road_name
            else:
                jurisdiction_type = 'city'
            
            # Get the appropriate road type from our database
            road_type = RoadType.objects.filter(name=highway_type).first()
            if not road_type:
                # If exact match not found, try to find a similar type
                if highway_type == 'tertiary':
                    road_type = RoadType.objects.filter(name__icontains='tertiary').first()
                elif highway_type in ['residential', 'living_street']:
                    road_type = RoadType.objects.filter(name__icontains='residential').first()
                elif highway_type == 'service':
                    road_type = RoadType.objects.filter(name__icontains='service').first()
                elif highway_type == 'unclassified':
                    road_type = RoadType.objects.filter(name__icontains='unclassified').first()
                
                if not road_type:
                    road_type = RoadType.objects.first()  # Fallback to first road type
            
            # For non-national roads, find the appropriate city agency
            if jurisdiction_type == 'city':
                if not city:
                    city = way['tags'].get('addr:city', '')
                mapping = RoadTypeAgencyMapping.objects.filter(
                    jurisdiction_type='city',
                    road_type=road_type,
                    agency__city__iexact=city
                ).first()
                
                if mapping:
                    return mapping.agency, highway_type, road_name
            
            # Fallback to default agency if no mapping found
            default_agency = Agency.objects.filter(name__icontains="DPWH").first()
            return default_agency, highway_type, road_name
        else:
            return None, None, None
    except Exception as e:
        print(f"Error in Overpass API: {e}")
        return None, None, None

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
                lat = request.POST.get('latitude')
                lon = request.POST.get('longitude')
                city = request.POST.get('city')
                agency, road_type_str, road_name = classify_road_and_assign_agency(lat, lon, city)
                if not agency:
                    agency = Agency.objects.select_for_update().first()  # fallback
                issue_type = IssueType.objects.select_for_update().get(name=request.POST.get('issue_type'))
                road_type = RoadType.objects.select_for_update().get(name=road_type_str or 'Asphalt')
            except (Agency.DoesNotExist, IssueType.DoesNotExist, RoadType.DoesNotExist) as e:
                print(f"Database object not found: {str(e)}")
                return JsonResponse({'error': 'Required data not found in database'}, status=400)
            except Exception as e:
                print(f"Error accessing database: {str(e)}")
                return JsonResponse({'error': 'Database error'}, status=500)

            # Use submitted date or default to today
            submitted_date = request.POST.get('date')
            if submitted_date:
                try:
                    report_date = datetime.strptime(submitted_date, '%Y-%m-%d').date()
                except Exception:
                    report_date = dt_date.today()
            else:
                report_date = dt_date.today()

            # Create the report
            try:
                report = Report.objects.create(
                    tracking_code=tracking_code,
                    description=request.POST.get('description'),
                    photo_url=photo_url,
                    latitude=lat,
                    longitude=lon,
                    address=request.POST.get('address'),
                    road_name=road_name or request.POST.get('road_name'),
                    assigned_agency=agency,
                    status_report_status='Pending',
                    citizen_name=request.POST.get('full_name'),
                    citizen_email=request.POST.get('email'),
                    issue_type=issue_type,
                    road_type=road_type,
                    date=report_date
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
                'message': 'Report submitted successfully',
                'assigned_agency': agency.name if agency else None,
                'road_type': road_type_str,
                'road_name': road_name
            })

        except Exception as e:
            print(f"Unexpected error in submit_report: {str(e)}")
            return JsonResponse({'error': str(e)}, status=500)

    return JsonResponse({'error': 'Method not allowed'}, status=405)

@require_GET
def analytics_reports_over_time(request):
    start = request.GET.get('start', '2020-01-01')  # Default to 2020
    end = request.GET.get('end', '2024-12-31')  # Default to 2024
    location = request.GET.get('location')
    submitter = request.GET.get('submitter')
    
    qs = Report.objects.all()
    
    # Apply date filters
    if start:
        qs = qs.filter(date__gte=parse_date(start))
    if end:
        qs = qs.filter(date__lte=parse_date(end))
    
    # Apply location filter
    if location and location != 'All Locations':
        qs = qs.filter(
            Q(address__icontains=location) |
            Q(city__icontains=location) |
            Q(barangay__icontains=location)
        )
    
    # Apply submitter filter
    if submitter:
        qs = qs.filter(
            Q(citizen_name__icontains=submitter) |
            Q(citizen_email__icontains=submitter)
        )
    
    # Group by month and get total count
    data = (
        qs.annotate(month=TruncMonth('date'))
          .values('month')
          .annotate(count=Count('id'))
          .order_by('month')
    )
    
    # Format for Chart.js
    result = {
        'labels': [item['month'].strftime('%B %Y') for item in data],
        'datasets': [{
            'label': 'Total Reports',
            'data': [item['count'] for item in data]
        }]
    }
    
    return JsonResponse(result)

@require_GET
def analytics_issues_by_type(request):
    start = request.GET.get('start')
    end = request.GET.get('end')
    location = request.GET.get('location')
    submitter = request.GET.get('submitter')
    qs = Report.objects.all()
    if start:
        qs = qs.filter(date__gte=parse_date(start))
    if end:
        qs = qs.filter(date__lte=parse_date(end))
    if location and location != 'All Locations':
        qs = qs.filter(
            Q(address__icontains=location) |
            Q(city__icontains=location) |
            Q(barangay__icontains=location)
        )
    if submitter:
        qs = qs.filter(
            Q(citizen_name__icontains=submitter) |
            Q(citizen_email__icontains=submitter)
        )
    data = (
        qs.values('issue_type__name')
        .annotate(count=Count('id'))
        .order_by('issue_type__name')
    )
    result = {row['issue_type__name']: row['count'] for row in data}
    return JsonResponse(result)

@require_GET
def analytics_issues_by_location(request):
    try:
        # Get filter parameters
        start = request.GET.get('start')
        end = request.GET.get('end')
        issue_type = request.GET.get('issue_type')
        location = request.GET.get('location')
        submitter = request.GET.get('submitter')
        
        # Initialize query with basic filtering
        qs = Report.objects.all()
        
        # Add date filters with error handling
        try:
            if start:
                start_date = parse_date(start)
                if start_date:
                    qs = qs.filter(date__gte=start_date)
            if end:
                end_date = parse_date(end)
                if end_date:
                    qs = qs.filter(date__lte=end_date)
        except Exception as e:
            print(f"Error parsing dates: {str(e)}")
            return JsonResponse({
                'error': 'Invalid date format',
                'details': str(e)
            }, status=400)
        
        # Add other filters
        if issue_type and issue_type != 'All Types':
            qs = qs.filter(issue_type__name=issue_type)
        if location and location != 'All Locations':
            qs = qs.filter(address__icontains=location)
        if submitter:
            qs = qs.filter(
                Q(citizen_name__icontains=submitter) |
                Q(citizen_email__icontains=submitter)
            )
        
        # Debug print
        print(f"Query SQL: {qs.query}")
        
        # Group by address and get total count
        try:
            data = (
                qs.exclude(address__isnull=True)  # Exclude null addresses
                .values('address')
                .annotate(count=Count('id'))
                .order_by('-count')  # Order by count in descending order
            )
            
            # Debug print
            print(f"Number of results: {len(data)}")
            
            # Format for Chart.js
            result = {}
            for row in data:
                if row['address']:  # Only process if address is not None
                    # Extract city from address (assuming format includes city)
                    address_parts = row['address'].split(',')
                    city = address_parts[-2].strip() if len(address_parts) > 1 else row['address'].strip()
                    
                    if city not in result:
                        result[city] = row['count']
                    else:
                        result[city] += row['count']
            
            # If no results, return empty data instead of error
            if not result:
                return JsonResponse({
                    'labels': [],
                    'datasets': [{
                        'label': 'Total Reports',
                        'data': []
                    }]
                })
            
            return JsonResponse(result)
            
        except Exception as e:
            print(f"Error in data aggregation: {str(e)}")
            return JsonResponse({
                'error': 'Error processing data',
                'details': str(e)
            }, status=500)
            
    except Exception as e:
        print(f"Unexpected error in analytics_issues_by_location: {str(e)}")
        return JsonResponse({
            'error': 'An unexpected error occurred',
            'details': str(e)
        }, status=500)

@require_GET
def get_report_data(request):
    try:
        # Get date range from request
        start_date = request.GET.get('start_date')
        end_date = request.GET.get('end_date')
        
        # Convert to datetime objects
        if start_date:
            start_date = datetime.strptime(start_date, '%Y-%m-%d').date()
        if end_date:
            end_date = datetime.strptime(end_date, '%Y-%m-%d').date()
        
        # Get reports within date range
        reports = Report.objects.all()
        if start_date:
            reports = reports.filter(date__gte=start_date)
        if end_date:
            reports = reports.filter(date__lte=end_date)
        
        # Get total reports per month
        monthly_data = reports.annotate(
            month=TruncMonth('date')
        ).values('month').annotate(
            total=Count('id')
        ).order_by('month')
        
        # Format data for chart
        months = [item['month'].strftime('%B %Y') for item in monthly_data]
        totals = [item['total'] for item in monthly_data]
        
        return JsonResponse({
            'months': months,
            'totals': totals
        })
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)

def seed_issue_types():
    # Delete existing issue types
    IssueType.objects.all().delete()
    
    # Define issue types to match CSV data
    issue_types = [
        'Pothole',
        'Drainage Blockage',
        'Faded Markings',
        'Broken Signage'
    ]
    
    # Seed issue types
    for issue_type in issue_types:
        IssueType.objects.create(name=issue_type)
    
    print("Issue types seeded successfully.")

def seed_reports():
    # Delete existing reports
    Report.objects.all().delete()
    
    # Seed issue types and road types if not already done
    seed_issue_types()
    seed_road_types()
    
    # Read CSV data
    csv_file_path = os.path.join(settings.BASE_DIR, 'infrastructure_reports_negros_occidental.csv')
    with open(csv_file_path, 'r') as file:
        reader = csv.DictReader(file)
        for row in reader:
            # Get or create issue type
            issue_type, _ = IssueType.objects.get_or_create(name=row['issue_type'])
            
            # Get or create road type
            road_type, _ = RoadType.objects.get_or_create(name=row['road_type'])
            
            # Create report
            Report.objects.create(
                tracking_code=row['tracking_code'],
                description=row['description'],
                photo_url=row['photo_url'],
                latitude=row['latitude'],
                longitude=row['longitude'],
                address=row['address'],
                road_name=row['road_name'],
                assigned_agency=Agency.objects.first(),  # Default agency
                status_report_status='Pending',
                citizen_name=row['citizen_name'],
                citizen_email=row['citizen_email'],
                issue_type=issue_type,
                road_type=road_type,
                date=datetime.strptime(row['date'], '%Y-%m-%d').date()
            )
    
    print("Reports seeded successfully.")