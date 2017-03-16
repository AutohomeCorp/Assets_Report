# -*- coding:utf-8 -*-
from rest_framework import viewsets
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
import json
import time
import datetime

from .serializers import AssetSerialzer
from . import models as apis_models

class AssetViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = apis_models.Asset.objects.all()
    serializer_class = AssetSerialzer


@api_view(['POST', 'PUT'])
def report(request):
    """
    汇报信息入库
    :param request:
    :return:
    """
    data = request.body

    try:
        data = json.loads(data)
    except ValueError as e:
        return Response({'code': -1, 'message': 'invalid data provided. Err:%s' % e}, status=status.HTTP_400_BAD_REQUEST)

    not_modify = data.pop('not_modify')
    data['setuptime'] = time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(int(data['setuptime'])))

    certname = data['certname']
    asset = apis_models.Asset.objects.filter(certname=certname)

    if len(asset) == 1:
        if not_modify == 1:
            asset.update(update_at=datetime.datetime.now())
        else:
            data['update_at'] = datetime.datetime.now()
            asset.update(**data)
    else:
        apis_models.Asset.objects.create(**data)

    return Response({'code': 0, 'message': 'success'}, status=status.HTTP_200_OK)
