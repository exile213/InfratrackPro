from django.db import models

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


class User(models.Model):
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
    photo_url = models.TextField()
    latitude = models.DecimalField(max_digits=10, decimal_places=7)
    longitude = models.DecimalField(max_digits=10, decimal_places=7)
    address = models.TextField()
    road_name = models.CharField(max_length=255)
    assigned_agency = models.ForeignKey(Agency, on_delete=models.CASCADE)
    status_report_status = models.CharField(max_length=100)
    citizen_name = models.CharField(max_length=255)
    citizen_email = models.EmailField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    issue_type = models.ForeignKey(IssueType, on_delete=models.CASCADE)
    road_type = models.ForeignKey(RoadType, on_delete=models.CASCADE)

    def __str__(self):
        return f"{self.tracking_code} - {self.issue_type.name}"
