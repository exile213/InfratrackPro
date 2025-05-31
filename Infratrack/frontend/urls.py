from django.urls import path
from . import views

app_name = 'frontend'

urlpatterns = [
    path('', views.home, name='home'),
    path('login/', views.login, name='login'),
    path('register-agency/', views.register_agency, name='register_agency'),
    path('dashboard/', views.dashboard, name='dashboard'),
    path('analytics/', views.analytics, name='analytics'),
    path('projects/', views.projects, name='projects'),
    path('resources/', views.resources, name='resources'),
    path('reports/', views.reports, name='reports'),
    path('profile/', views.profile, name='profile'),
    path('admin/', views.admin_interface, name='admin'),
    path('404/', views.not_found, name='404'),
] 