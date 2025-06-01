from django.contrib import admin

from .models import Agency, Role, Users, IssueType, RoadType, InfrastructureMap, Report, RoadTypeAgencyMapping


admin.site.register(Agency)
admin.site.register(Role)
admin.site.register(Users)
admin.site.register(IssueType)
admin.site.register(RoadType)
admin.site.register(InfrastructureMap)
admin.site.register(Report)
admin.site.register(RoadTypeAgencyMapping)
