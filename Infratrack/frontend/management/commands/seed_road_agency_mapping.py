from django.core.management.base import BaseCommand
from frontend.models import Agency, RoadType, RoadTypeAgencyMapping

class Command(BaseCommand):
    help = 'Seed road type to agency mapping data'

    def handle(self, *args, **kwargs):
        self.stdout.write("🔁 Seeding road type to agency mapping...")

        # Clear existing mappings
        RoadTypeAgencyMapping.objects.all().delete()

        # Get agencies
        dpwh = Agency.objects.filter(name__icontains="DPWH").first()
        city_agencies = Agency.objects.filter(name__icontains="City Engineer").all()

        # Get road types
        road_types = RoadType.objects.all()

        # Create mappings
        mappings = []

        # National roads (DPWH)
        for road_type in road_types:
            if dpwh:
                mappings.append(RoadTypeAgencyMapping(
                    road_type=road_type,
                    agency=dpwh,
                    jurisdiction_type='national'
                ))

        # City roads (City Engineering Offices)
        for city_agency in city_agencies:
            for road_type in road_types:
                mappings.append(RoadTypeAgencyMapping(
                    road_type=road_type,
                    agency=city_agency,
                    jurisdiction_type='city'
                ))

        # Bulk create mappings
        RoadTypeAgencyMapping.objects.bulk_create(mappings)

        self.stdout.write(self.style.SUCCESS("✅ Road type to agency mapping created successfully!")) 