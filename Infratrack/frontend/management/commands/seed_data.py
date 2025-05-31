from django.core.management.base import BaseCommand
from frontend.models import IssueType, RoadType

class Command(BaseCommand):
    help = 'Seeds the database with initial data for issue types and road types'

    def handle(self, *args, **kwargs):
        self.stdout.write('Seeding data...')

        # Create issue types
        issue_types = [
            {'name': 'Pothole', 'description': 'Road surface damage causing holes'},
            {'name': 'Drainage', 'description': 'Issues with drainage systems'},
            {'name': 'Streetlight', 'description': 'Problems with street lighting'},
            {'name': 'Road Marking', 'description': 'Faded or damaged road markings'},
            {'name': 'Signage', 'description': 'Damaged or missing road signs'},
            {'name': 'Other', 'description': 'Other infrastructure issues'}
        ]

        for issue_type in issue_types:
            IssueType.objects.get_or_create(
                name=issue_type['name'],
                defaults={'description': issue_type['description']}
            )

        # Create road types
        road_types = [
            {'name': 'Asphalt', 'description': 'Asphalt paved roads'},
            {'name': 'Concrete', 'description': 'Concrete paved roads'},
            {'name': 'Gravel', 'description': 'Gravel roads'},
            {'name': 'Dirt', 'description': 'Unpaved dirt roads'}
        ]

        for road_type in road_types:
            RoadType.objects.get_or_create(
                name=road_type['name'],
                defaults={'description': road_type['description']}
            )

        self.stdout.write(self.style.SUCCESS('Successfully seeded data')) 