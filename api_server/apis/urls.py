from django.conf.urls import url, include
from django.contrib import admin
from rest_framework import routers, serializers, viewsets
from . import views

router = routers.DefaultRouter()
router.register(r'assets', views.AssetViewSet)

urlpatterns = [
    url(r'^', include(router.urls)),
    url(r'asset/report/', views.report, name='asset_report'),

]
