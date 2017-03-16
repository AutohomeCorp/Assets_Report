# -*- coding:utf-8 -*-
from django.db import models
from jsonfield import JSONField
# Create your models here.


class Asset(models.Model):
    certname = models.CharField(max_length=50, unique=True)
    sn = models.CharField(u'SN', max_length=100, unique=True)
    manufactory = models.CharField(u'服务器厂商', max_length=50)
    productname = models.CharField(u'服务器产品名称', max_length=50)
    model = models.CharField(u'服务器型号', max_length=50)
    os_type = models.CharField(u'操作系统类型', max_length=10)
    os_distribution = models.CharField(u'操作系统发行版本', max_length=10)
    os_release = models.CharField(u'操作系统版本号', max_length=10)
    cpu_count = models.IntegerField(u'CPU物理个数', default=0)
    cpu_core_count = models.IntegerField(u'CPU逻辑核数', default=0)
    cpu_model = models.CharField(u'CPU型号', max_length=50)
    nic_count = models.IntegerField(u'网卡个数', default=0)
    nic = JSONField(u'网卡信息')
    raid_adaptor_count = models.IntegerField(u'Raid卡控制器个数')
    raid_adaptor = JSONField(u'Raid卡控制器纤细信息', null=True)
    raid_type = models.CharField(u'Raid类型', max_length=50, null=True)
    physical_disk_driver = JSONField(u'硬盘详细信息', null=True)
    ram_size = models.IntegerField(u'内存总容量', default=0)
    ram_slot = JSONField(u'内存详细信息', null=True)
    setuptime = models.DateTimeField(u'系统安装时间', blank=True, null=True)
    create_at = models.DateTimeField(blank=True, auto_now_add=True)
    update_at = models.DateTimeField(blank=True, auto_now=True)

    def __str__(self):
        return self.certname

