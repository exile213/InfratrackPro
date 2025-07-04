# Generated by Django 5.2.1 on 2025-06-01 14:56

import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('frontend', '0002_rename_user_users'),
    ]

    operations = [
        migrations.CreateModel(
            name='RoadTypeAgencyMapping',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('jurisdiction_type', models.CharField(choices=[('national', 'National'), ('city', 'City'), ('provincial', 'Provincial'), ('barangay', 'Barangay')], max_length=50)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('agency', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='frontend.agency')),
                ('road_type', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='frontend.roadtype')),
            ],
            options={
                'unique_together': {('road_type', 'agency', 'jurisdiction_type')},
            },
        ),
    ]
