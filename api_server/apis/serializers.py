# -*- coding:utf-8 -*-
from rest_framework import serializers
from . import models as apis_models


class AssetSerialzer(serializers.ModelSerializer):

    class Meta:
        model = apis_models.Asset
        fields = '__all__'
