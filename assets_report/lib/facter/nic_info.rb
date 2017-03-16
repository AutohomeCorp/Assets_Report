# encoding: utf-8
require "rubygems"
require 'json'

def more_ip_plan_for_win(nic_name,nic)
  nic_name_count = 0
  new_nic_name = nic_name
  while nic.has_key?(new_nic_name)
    new_nic_name = new_nic_name.split(":")[0] + ":" + nic_name_count.to_s
    nic_name_count += 1
  end
  nic[new_nic_name] = {}
  nic[new_nic_name]['macaddress'] = nic[nic_name]['macaddress']
  nic[new_nic_name]['ipaddress'] = nic[nic_name]['ipaddress']
  nic[new_nic_name]['netmask'] = nic[nic_name]['netmask']
  return nic
end

def more_ip_plan_for_linux(nic_name,nic,new_nic_name)
  nic[new_nic_name] = {}
  nic[new_nic_name]['macaddress'] = nic[nic_name]['macaddress']
  nic[new_nic_name]['ipaddress'] = nic[nic_name]['ipaddress']
  nic[new_nic_name]['netmask'] = nic[nic_name]['netmask']
  return nic
end

def full_nic_for_win(nic_name,nic)
  nic_name_count = 0
  new_nic_name = nic_name + ":" + nic_name_count.to_s
  if nic[nic_name].has_key?('ipaddress')
    if nic[nic_name]['ipaddress'] == nil
      nic[nic_name]['ipaddress'] = ''
    end
  else
    nic[nic_name]['ipaddress'] = ''
  end

  while nic.has_key?(new_nic_name)
    nic[new_nic_name]['hardware'] = 1
    nic[new_nic_name]['model'] = ''
    if nic[new_nic_name]['ipaddress'] == nil
      nic[new_nic_name]['ipaddress'] = ''
    end
    nic_name_count += 1
    new_nic_name = new_nic_name.split(":")[0] + ":" + nic_name_count.to_s
  end
  for x in nic
    if not x[1].has_key?('hardware')
      x[1]['hardware'] = 1
    end
    if not x[1].has_key?('model')
      x[1]['model'] = ''
    end
  end
  return nic
end

def full_nic_for_linux(nic_name,nic)
  nic_name_count = 0
  new_nic_name = nic_name + ":" + nic_name_count.to_s
  if nic[nic_name].has_key?('ipaddress')
    if nic[nic_name]['ipaddress'] == nil
      nic[nic_name]['ipaddress'] = ''
    end
  else
    nic[nic_name]['ipaddress'] = ''
  end
  if nic[nic_name].has_key?('netmask')
    if nic[nic_name]['netmask'] == nil
      nic[nic_name]['netmask'] = ''
    end
  else
    nic[nic_name]['netmask'] = ''
  end
  while nic.has_key?(new_nic_name)
    if nic[new_nic_name]['ipaddress'] == nil
      nic[new_nic_name]['ipaddress'] = ''
    end
    nic_name_count += 1
    new_nic_name = new_nic_name.split(":")[0] + ":" + nic_name_count.to_s
  end
  for x in nic
    if not x[1].has_key?('hardware')
      x[1]['hardware'] = 1
    end
    if not x[1].has_key?('model')
      x[1]['model'] = ''
    end
  end
  return nic
end

def get_ip_for_win_ZH_CN()
  nic = {}
  ipconfig_replace = %x{"ipconfig"/all"}.gsub(" ","")
  ipconfig_arr = ipconfig_replace.split("\n")
  nil_arr = [""]
  ipconfig_arr = ipconfig_arr - nil_arr
  for ipline in ipconfig_arr
    ip_info = ipline.split(":")
    if ipline.include?"以太网适配器".encode('gbk')
      nic_name = ipline.gsub("以太网适配器".encode('gbk'),"").gsub(":","")
      nic[nic_name] = {}
      nic[nic_name]['hardware'] = 1
      nic[nic_name]['model'] = ''
    elsif ipline.include?"物理地址".encode('gbk')
      nic[nic_name]['macaddress'] = ip_info[1]
    elsif ipline.include?"IPv4".encode('gbk')
      if nic[nic_name].has_key?('ipaddress')
        nic = more_ip_plan_for_win(nic_name, nic)
      end
      nic[nic_name]['ipaddress'] = ip_info[1].split("(")[0]
    elsif ipline.include?"子网掩码".encode('gbk')
      nic[nic_name]['netmask'] = ip_info[1]
    nic = full_nic_for_win(nic_name,nic)
    end
  end
  return nic
end

def get_ip_for_win_EN_US()
  nic = {}
  ipconfig_replace = %x{"ipconfig"/all"}
  ipconfig_arr = ipconfig_replace.split("\n")
  nil_arr = [""]
  ipconfig_arr = ipconfig_arr - nil_arr
  for ipline in ipconfig_arr
    ip_info = ipline.split(":")
    if (ipline.include?"Ethernet" and ipline.include?"adapter")
      nic_name = ipline.gsub("Ethernet","").gsub("adapter","").gsub(":","").strip()
      nic[nic_name] = {}
      nic[nic_name]['hardware'] = 1
      nic[nic_name]['model'] = ''
    end
    if ip_info.length > 1
      if (ipline.include?"Physical" and ipline.include?"Address")
        nic[nic_name]['macaddress'] = ip_info[1].strip()
      elsif ipline.include?"IPv4"
        if nic[nic_name].has_key?('ipaddress')
          nic = more_ip_plan_for_win(nic_name, nic)
        end
        nic[nic_name]['ipaddress'] = ip_info[1].split("(")[0].strip()
      elsif (ipline.include?"Subnet" and ipline.include?"Mask")
        nic[nic_name]['netmask'] = ip_info[1].strip()
      end
      if not nic_name == nil
        nic = full_nic_for_win(nic_name,nic)
      end
    end
  end
  return nic
end

def get_ip_for_win()
  ipconfig_replace = %x{"ipconfig"/all"}.gsub(" ","")
  if ipconfig_replace.include?"以太网适配器".encode('gbk')
    nic = get_ip_for_win_ZH_CN()
  else
    nic = get_ip_for_win_EN_US()
  end
  return nic
end

def get_ip_for_linux()
  nic = {}
  ipconfig_replace = `ip address show`
  ipconfig_arr = ipconfig_replace.split("\n")
  ipconfig_arr = ipconfig_arr - ['']
  for ipline in ipconfig_arr
    if not ipline[0, 1] == " "
      nic_name = ipline.split(" ")[1].gsub(" ","")
      if nic_name[-1, 1] == ":"
        nic_name = nic_name.slice(0, nic_name.length - 1 )
      end
      nic[nic_name] = {}
      nic[nic_name]['hardware'] = 1
      nic[nic_name]['model'] = ''
    elsif (ipline.include?"inet" and not(ipline.include?"inet6"))
      ipconfig_replace = ipline.split(" ") - [""]
      if not ipconfig_replace[-1] == nic_name
        nic = more_ip_plan_for_linux(nic_name,nic,ipconfig_replace[-1])
      end
      match_auto = /\d+\.\d+\.\d+\.\d+/.match(ipconfig_replace[1])
      nic[nic_name]['ipaddress'] = match_auto[0]
      nic[nic_name]['netmask'] = auto_netmask(ipconfig_replace[1].slice(ipconfig_replace[1].rindex("/") + 1, 10))
    elsif not /([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}/.match(ipline) == nil
      nic[nic_name]['macaddress'] = /([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}/.match(ipline)[0]
    end
    nic = full_nic_for_linux(nic_name,nic)
  end
  return nic
end

def check_mac(nic)
  for x in nic
    if not x[1].has_key?('macaddress')
      nic.delete(x[0])
      next
    end
    if x[1]['ipaddress'] == '127.0.0.1'
      #p 'del from ip'
      nic.delete(x[0])
      next
    end
    if x[1]['macaddress'] == nil
      nic.delete(x[0])
      next
    end
    if x[0].include?('lo:')
      #p 'del from name'
      nic.delete(x[0])
      next
    end
  end
  return nic
end

def auto_netmask(num)
  count = num.to_i/8
  lift = num.to_i%8
  netmask = "255." * count + Integer("0b" + "1" * lift +"0" * (8 - lift)).to_s
  netmask_info = netmask.split(".")
  if netmask_info.size > 4
    netmask = netmask_info[0] + "." + netmask_info[1] + "." + netmask_info[1] + "." + netmask_info[1]
  elsif netmask_info.size < 4
    new_arr = netmask_info
    while new_arr.size < 4
      new_arr.push('0')
    end
    netmask = new_arr.join(".")
  end
  return netmask
end

Facter.add(:nic_info) do
  confine :kernel => 'Linux'
  setcode do
    nic_res = get_ip_for_linux()
    nic_res = check_mac(nic_res)
    nic_res = JSON.dump(nic_res)
  end
end

Facter.add(:nic_info) do
  confine :kernel => 'windows'
  setcode do
    nic_res = get_ip_for_win()
    nic_res = check_mac(nic_res)
    nic_res = JSON.dump(nic_res)
  end
end
