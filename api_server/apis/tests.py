# -*- coding:utf-8 -*-
import json
import requests

data = {
    "cpu_count": "2",
    "raid_type": "Primary-1, Secondary-0, RAID Level Qualifier-0",
    "nic_count": 8,
    "ram_size": 128,
    "setuptime": "1423552321",
    "manufactory": "Dell Inc.",
    "cpu_core_count": "24",
    "ram_slot": {
        "DIMM_B9": {
            "model": "DDR3",
            "capacity": 0,
            "sn": "",
            "manufactory": ""
        },
        "DIMM_B8": {
            "model": "DDR3",
            "capacity": 0,
            "sn": "",
            "manufactory": ""
        },
        "DIMM_B7": {
            "model": "DDR3",
            "capacity": 0,
            "sn": "",
            "manufactory": ""
        },
        "DIMM_B6": {
            "model": "DDR3",
            "capacity": 0,
            "sn": "",
            "manufactory": ""
        },
        "DIMM_B5": {
            "model": "DDR3",
            "capacity": 0,
            "sn": "",
            "manufactory": ""
        },
        "DIMM_B4": {
            "model": "DDR3",
            "capacity": 16,
            "sn": "0001",
            "manufactory": "00CE00B300CE"
        },
        "DIMM_B3": {
            "model": "DDR3",
            "capacity": 16,
            "sn": "0002",
            "manufactory": "00CE00B300CE"
        },
        "DIMM_B2": {
            "model": "DDR3",
            "capacity": 16,
            "sn": "0003",
            "manufactory": "00CE00B300CE"
        },
        "DIMM_B1": {
            "model": "DDR3",
            "capacity": 16,
            "sn": "0004",
            "manufactory": "00CE00B300CE"
        },
        "DIMM_B12": {
            "model": "DDR3",
            "capacity": 0,
            "sn": "",
            "manufactory": ""
        },
        "DIMM_B11": {
            "model": "DDR3",
            "capacity": 0,
            "sn": "",
            "manufactory": ""
        },
        "DIMM_B10": {
            "model": "DDR3",
            "capacity": 0,
            "sn": "",
            "manufactory": ""
        },
        "DIMM_A6": {
            "model": "DDR3",
            "capacity": 0,
            "sn": "",
            "manufactory": ""
        },
        "DIMM_A7": {
            "model": "DDR3",
            "capacity": 0,
            "sn": "",
            "manufactory": ""
        },
        "DIMM_A4": {
            "model": "DDR3",
            "capacity": 16,
            "sn": "0005",
            "manufactory": "00CE00B300CE"
        },
        "DIMM_A5": {
            "model": "DDR3",
            "capacity": 0,
            "sn": "",
            "manufactory": ""
        },
        "DIMM_A2": {
            "model": "DDR3",
            "capacity": 16,
            "sn": "0006",
            "manufactory": "00CE00B300CE"
        },
        "DIMM_A3": {
            "model": "DDR3",
            "capacity": 16,
            "sn": "0007",
            "manufactory": "00CE00B300CE"
        },
        "DIMM_A1": {
            "model": "DDR3",
            "capacity": 16,
            "sn": "0008",
            "manufactory": "00CE00B300CE"
        },
        "DIMM_A8": {
            "model": "DDR3",
            "capacity": 0,
            "sn": "",
            "manufactory": ""
        },
        "DIMM_A9": {
            "model": "DDR3",
            "capacity": 0,
            "sn": "",
            "manufactory": ""
        },
        "DIMM_A10": {
            "model": "DDR3",
            "capacity": 0,
            "sn": "",
            "manufactory": ""
        },
        "DIMM_A11": {
            "model": "DDR3",
            "capacity": 0,
            "sn": "",
            "manufactory": ""
        },
        "DIMM_A12": {
            "model": "DDR3",
            "capacity": 0,
            "sn": "",
            "manufactory": ""
        }
    },
    "raid_adaptor_count": 1,
    "raid_adaptor": {
        "adaptor_0": {
            "model": "PERC H710P Mini",
            "memory_size": "1024MB",
            "sn": "33J001"
        }
    },
    "nic": {
        "bond0.112": {
            "macaddress": "a0:36:9f:1d:75:f1",
            "switch_port": "NULL",
            "hardware": 1,
            "netmask": "",
            "model": "",
            "ipaddress": ""
        },
        "bond0": {
            "macaddress": "a0:36:9f:1d:75:f2",
            "switch_port": "NULL",
            "hardware": 1,
            "netmask": "",
            "model": "",
            "ipaddress": ""
        },
        "em4": {
            "macaddress": "a0:36:9f:1d:75:f3",
            "switch_port": "NULL",
            "hardware": 1,
            "netmask": "",
            "model": "",
            "ipaddress": ""
        },
        "bond0.112@bond0": {
            "macaddress": "ba0:36:9f:1d:75:f4",
            "switch_port": "NULL",
            "hardware": 1,
            "netmask": "255.255.224.0",
            "model": "",
            "ipaddress": "192.168.1.1"
        },
        "em1": {
            "macaddress": "a0:36:9f:1d:75:f5",
            "switch_port": "NULL",
            "hardware": 1,
            "netmask": "",
            "model": "",
            "ipaddress": ""
        },
        "em3": {
            "macaddress": "a0:36:9f:1d:75:f6",
            "switch_port": "NULL",
            "hardware": 1,
            "netmask": "",
            "model": "",
            "ipaddress": ""
        },
        "em2": {
            "macaddress": "a0:36:9f:1d:75:f7",
            "switch_port": "NULL",
            "hardware": 1,
            "netmask": "",
            "model": "",
            "ipaddress": ""
        },
        "p3p2": {
            "macaddress": "a0:36:9f:1d:75:f8",
            "switch_port": "NULL",
            "hardware": 1,
            "netmask": "",
            "model": "",
            "ipaddress": ""
        },
        "p3p1": {
            "macaddress": "a0:36:9f:1d:75:f9",
            "switch_port": "NULL",
            "hardware": 1,
            "netmask": "",
            "model": "",
            "ipaddress": ""
        }
    },
    "certname": "192.168.1.1",
    "cpu_model": "Intel(R) Xeon(R) CPU E5-2620 0 @ 2.00GHz",
    "os_type": "Linux",
    "model": "PowerEdge R620",
    "productname": "PowerEdge R620",
    "physical_disk_driver": [
        {
            "slot": "0",
            "capacity": 838,
            "adaptor": "adaptor_0",
            "model": "SEAGATE LS06S0N05CDV",
            "enclosure": "32",
            "iface_type": "SAS"
        },
        {
            "slot": "1",
            "capacity": 838,
            "adaptor": "adaptor_0",
            "model": "SEAGATE LS06S0N05K5Z",
            "enclosure": "32",
            "iface_type": "SAS"
        },
        {
            "slot": "2",
            "capacity": 838,
            "adaptor": "adaptor_0",
            "model": "SEAGATE ST96S0N03W9A",
            "enclosure": "32",
            "iface_type": "SAS"
        },
        {
            "slot": "3",
            "capacity": 838,
            "adaptor": "adaptor_0",
            "model": "SEAGATE ST900MM0006",
            "enclosure": "32",
            "iface_type": "SAS"
        }
    ],
    "sn": "CL68YX001",
    "os_release": "6.7",
    "not_modify": 0,
    "os_distribution": "CentOS"
}
url = 'http://localhost/api/v1.0/asset/report/'
myreq = requests.post(url, data=json.dumps(data))
print(myreq.status_code)
print(myreq.content)
