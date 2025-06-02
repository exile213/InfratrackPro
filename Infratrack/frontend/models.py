from django.db import models
from django.core.management.base import BaseCommand

# Create your models here.
from django.db import models

class Agency(models.Model):
    name = models.CharField(max_length=255)
    city = models.CharField(max_length=255)
    coverage_area = models.TextField()
    contact_email = models.EmailField()
    contact_phone = models.CharField(max_length=50)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name


class Role(models.Model):  # Suggested addition
    name = models.CharField(max_length=100)

    def __str__(self):
        return self.name


class Users(models.Model):
    username = models.CharField(max_length=150, unique=True)
    email = models.EmailField(unique=True)
    password = models.CharField(max_length=255)
    full_name = models.CharField(max_length=255)
    role_user = models.ForeignKey(Role, on_delete=models.CASCADE)
    agency = models.ForeignKey(Agency, on_delete=models.SET_NULL, null=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    last_login = models.DateTimeField(null=True, blank=True)

    def __str__(self):
        return self.username


class IssueType(models.Model):
    name = models.CharField(max_length=255)
    description = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name


class RoadType(models.Model):
    name = models.CharField(max_length=255)
    description = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name


class RoadTypeAgencyMapping(models.Model):
    road_type = models.ForeignKey(RoadType, on_delete=models.CASCADE)
    agency = models.ForeignKey(Agency, on_delete=models.CASCADE)
    jurisdiction_type = models.CharField(max_length=50, choices=[
        ('national', 'National'),
        ('city', 'City'),
        ('provincial', 'Provincial'),
        ('barangay', 'Barangay')
    ])
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('road_type', 'agency', 'jurisdiction_type')

    def __str__(self):
        return f"{self.road_type.name} - {self.agency.name} ({self.jurisdiction_type})"


class InfrastructureMap(models.Model):
    road_name = models.CharField(max_length=255)
    city = models.CharField(max_length=255)
    province = models.CharField(max_length=255)
    infrastructure_typ_text = models.CharField(max_length=255)
    assigned_agency = models.ForeignKey(Agency, on_delete=models.CASCADE)
    coordinates = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.road_name


class Report(models.Model):
    tracking_code = models.CharField(max_length=100)
    description = models.TextField()
    photo_url = models.TextField(null=True, blank=True)
    latitude = models.DecimalField(max_digits=10, decimal_places=7, null=True, blank=True)
    longitude = models.DecimalField(max_digits=10, decimal_places=7, null=True, blank=True)
    address = models.TextField(null=True, blank=True)
    road_name = models.CharField(max_length=255)
    assigned_agency = models.ForeignKey(Agency, on_delete=models.CASCADE)
    status_report_status = models.CharField(max_length=100)
    citizen_name = models.CharField(max_length=255)
    citizen_email = models.EmailField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    created_by = models.ForeignKey(Users, on_delete=models.SET_NULL, null=True, blank=True)
    issue_type = models.ForeignKey(IssueType, on_delete=models.CASCADE)
    road_type = models.ForeignKey(RoadType, on_delete=models.CASCADE)
    date = models.DateField(null=True, blank=True)

    def __str__(self):
        return f"{self.tracking_code} - {self.issue_type.name}"

# Management command for seeding agencies
class Command(BaseCommand):
    help = 'Seed the Agency table with default agencies.'

    def handle(self, *args, **options):
        agencies = [
            {"name": "DPWH District 1", "city": "", "coverage_area": "National Roads District 1", "contact_email": "dpwh1@example.com", "contact_phone": "1234567890"},
            {"name": "DPWH District 5", "city": "", "coverage_area": "National Roads District 5", "contact_email": "dpwh5@example.com", "contact_phone": "1234567891"},
            {"name": "City Engineer of Victorias", "city": "Victorias", "coverage_area": "Victorias City", "contact_email": "victorias.engineer@example.com", "contact_phone": "1234567892"},
            {"name": "City Engineer of Silay", "city": "Silay", "coverage_area": "Silay City", "contact_email": "silay.engineer@example.com", "contact_phone": "1234567893"},
            {"name": "City Engineer of Talisay", "city": "Talisay", "coverage_area": "Talisay City", "contact_email": "talisay.engineer@example.com", "contact_phone": "1234567894"},
            {"name": "City Engineer of Bacolod", "city": "Bacolod", "coverage_area": "Bacolod City", "contact_email": "bacolod.engineer@example.com", "contact_phone": "1234567895"},
        ]
        for agency_data in agencies:
            agency, created = Agency.objects.get_or_create(
                name=agency_data["name"],
                defaults={
                    "city": agency_data["city"],
                    "coverage_area": agency_data["coverage_area"],
                    "contact_email": agency_data["contact_email"],
                    "contact_phone": agency_data["contact_phone"],
                }
            )
            if created:
                self.stdout.write(self.style.SUCCESS(f'Created agency: {agency.name}'))
            else:
                self.stdout.write(self.style.WARNING(f'Agency already exists: {agency.name}'))
