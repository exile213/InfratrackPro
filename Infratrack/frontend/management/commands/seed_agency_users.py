from django.core.management.base import BaseCommand
from frontend.models import Agency, Users, Role
from django.contrib.auth.hashers import make_password

class Command(BaseCommand):
    help = 'Seed Users for each Agency.'

    def handle(self, *args, **options):
        # Ensure the Agency Admin role exists
        role, _ = Role.objects.get_or_create(name='Agency Admin')
        agencies = Agency.objects.all()
        for agency in agencies:
            username = agency.name.lower().replace(' ', '_')
            email = agency.contact_email
            password = make_password('defaultpassword123')  # Set a default password
            user, created = Users.objects.get_or_create(
                username=username,
                defaults={
                    'email': email,
                    'password': password,
                    'full_name': agency.name,
                    'role_user': role,
                    'agency': agency,
                    'is_active': True,
                }
            )
            if created:
                self.stdout.write(self.style.SUCCESS(f'Created user for agency: {agency.name} (username: {username})'))
            else:
                self.stdout.write(self.style.WARNING(f'User already exists for agency: {agency.name} (username: {username})')) 