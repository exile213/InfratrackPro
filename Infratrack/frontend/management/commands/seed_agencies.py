from django.core.management.base import BaseCommand
from frontend.models import Agency

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