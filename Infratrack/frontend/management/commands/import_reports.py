import csv
from django.core.management.base import BaseCommand
from django.utils import timezone
from frontend.models import Agency, IssueType, RoadType, Report

class Command(BaseCommand):
    help = 'Import infrastructure reports from CSV for DPWH District 1'

    def handle(self, *args, **kwargs):
        agency = Agency.objects.filter(name__icontains='DPWH').first()
        if not agency:
            self.stdout.write(self.style.ERROR('No DPWH agency found!'))
            return
        road_type = RoadType.objects.first()  # Use the first road type as default
        if not road_type:
            self.stdout.write(self.style.ERROR('No RoadType found!'))
            return
        with open('infrastructure_reports_negros_occidental.csv', newline='', encoding='utf-8') as csvfile:
            reader = csv.DictReader(csvfile)
            for row in reader:
                issue_type_obj = IssueType.objects.filter(name__iexact=row['issue_type']).first()
                if not issue_type_obj:
                    self.stdout.write(self.style.WARNING(f"IssueType not found: {row['issue_type']} (row id {row['id']})"))
                    continue
                # Parse date_reported
                try:
                    # Try different date formats
                    date_formats = ['%d/%m/%Y', '%Y-%m-%d', '%m/%d/%Y', '%d-%m-%Y']
                    created_at = None
                    date_value = None
                    for date_format in date_formats:
                        try:
                            dt = timezone.datetime.strptime(row['date_reported'], date_format)
                            created_at = dt
                            date_value = dt.date()
                            break
                        except ValueError:
                            continue
                    
                    if not created_at:
                        self.stdout.write(self.style.WARNING(f"Invalid date format for row id {row['id']}: {row['date_reported']}"))
                        created_at = timezone.now()
                        date_value = created_at.date()
                except Exception as e:
                    self.stdout.write(self.style.WARNING(f"Error parsing date for row id {row['id']}: {str(e)}"))
                    created_at = timezone.now()
                    date_value = created_at.date()

                # Compose address
                address = f"{row['street']}, {row['barangay']}, {row['city']}, {row['province']}"
                # Insert report
                report = Report.objects.create(
                    tracking_code=f"DPWH{row['id']}",
                    description=row['description'],
                    photo_url=row['photo'] or '',
                    latitude=None,
                    longitude=None,
                    address=address,
                    road_name=row['street'],
                    assigned_agency=agency,
                    status_report_status='Active',
                    citizen_name=row['full_name'] or 'Anonymous',
                    citizen_email=row['email'] or 'anonymous@example.com',
                    created_at=created_at,
                    updated_at=created_at,  # Set updated_at to same as created_at
                    issue_type=issue_type_obj,
                    road_type=road_type, # Set created_by to None since we don't have user info
                    date=date_value
                )
                self.stdout.write(self.style.SUCCESS(f"Imported report {report.tracking_code}")) 