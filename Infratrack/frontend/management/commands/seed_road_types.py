from django.core.management.base import BaseCommand
from frontend.models import RoadType

class Command(BaseCommand):
    help = 'Seed the RoadType table with common road types from OpenStreetMap.'

    def handle(self, *args, **options):
        road_types = [
            {
                "name": "motorway",
                "description": "Major highways, expressways, and freeways"
            },
            {
                "name": "trunk",
                "description": "Major roads, often connecting cities"
            },
            {
                "name": "primary",
                "description": "Primary roads, major arterial routes"
            },
            {
                "name": "secondary",
                "description": "Secondary roads, connecting primary roads"
            },
            {
                "name": "tertiary",
                "description": "Tertiary roads, connecting secondary roads"
            },
            {
                "name": "residential",
                "description": "Residential streets and local roads"
            },
            {
                "name": "service",
                "description": "Service roads, access roads"
            },
            {
                "name": "unclassified",
                "description": "Unclassified roads"
            },
            {
                "name": "living_street",
                "description": "Living streets, pedestrian priority"
            }
        ]

        for road_type_data in road_types:
            road_type, created = RoadType.objects.get_or_create(
                name=road_type_data["name"],
                defaults={
                    "description": road_type_data["description"]
                }
            )
            if created:
                self.stdout.write(self.style.SUCCESS(f'Created road type: {road_type.name}'))
            else:
                self.stdout.write(self.style.WARNING(f'Road type already exists: {road_type.name}')) 