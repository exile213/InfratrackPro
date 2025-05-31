from django.contrib import admin

from .models import Agency, Role, User, IssueType, RoadType, InfrastructureMap, Report

admin.site.register(Agency)
admin.site.register(Role)
admin.site.register(User)
admin.site.register(IssueType)
admin.site.register(RoadType)
admin.site.register(InfrastructureMap)
admin.site.register(Report)
