$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include?(File.dirname(__FILE__))
require "rubygems"
require 'pp'
require 'json'
#require_relative 'utils'
require 'utils'

def mega_patter_match(needle)
  grep_pattern = ['Adapter', 'Slot', 'Raw Size', 'Inquiry', 'PD Type', 'Enclosure Device ID']
  grep_pattern.each do |pattern|
    return true if needle.start_with?(pattern)
  end
  return false
end

def megacli_get_disk_metric(cmd)
  result = []

  output = Utils.facter_exec(cmd)
  if output.strip.empty?
    return result
  end

  filted_content = output.split("\n").select do |line|
    mega_patter_match(line)
  end

  filted_content_string = filted_content.join("\n")

  adaptor_section = filted_content_string.split(/Adapter.*/).select {|e| not e.strip.empty? }
  adaptor_section.each_with_index do |section, adaptor_idx|

    pair_sequence = []
    section.split("\n").each do |record|
      next if record.strip().empty?
      key, value = record.split(":")
      pair_sequence.push([key.strip, value.strip])
    end

    first_flag = pair_sequence[0][0]
    element = {}
    pair_sequence.each_with_index do |pair, idx|
      key, value = pair

      if key == first_flag
        element[key] = value

        # this is the last one , or , it comes the duplicated key
      elsif (idx+1) == pair_sequence.size or pair_sequence[idx+1][0] == first_flag
        element[key] = value
        element['adaptor'] = "adaptor_#{adaptor_idx}"
        result.push(element)
        element = {}
      else
        element[key] = value
      end
    end

  end
  # convert key name to uniform name
  response = []
  result.each do |e|
    _d = {}
    e.each do |k, v|
      if k == 'Slot Number'
        _d['slot'] = v
      elsif k == 'PD Type'
        _d['iface_type'] = v
      elsif k == 'Raw Size'
        # v like this: "138.803 GB [0x1159bb10 Sectors]"
        _segment = v.split()
        unit = _segment[1].strip
        if unit == 'GB'
          _d['capacity'] = _segment[0].to_i
        elsif unit == 'TB'
          _d['capacity'] = _segment[0].to_f.round * 1024
        elsif unit == 'MB'
          _d['capacity'] = _segment[0].to_i / 1024
        end
      elsif k == 'Inquiry Data'
        _d['model'] = v
      elsif k == 'Enclosure Device ID'
        _d['enclosure'] = v
      else
        _d[k] = v
      end
    end
    response.push(_d)
  end

  return response
end


def hpcli_get_disk_metric(cmd)

  response = []
  output = Utils.facter_exec(cmd)

  if not output.empty?

    enclosure = ''
    output.split("\n").each do |line|
      #   "physicaldrive 2I:1:5 (port 2I:box 1:bay 5, SAS, 300 GB, OK)"
      #   1:"2I" 2:"2I" 3:"SAS" 4:"300">
      enclosure_pattern = /.*Slot (\d+).*/
      drive_pattern = /^physicaldrive (\w+:\d:\d) \(port.*\w+:box \d:bay \d, (.+?), (\d+) (\w{2}),.*/
      enclosure_m = enclosure_pattern.match(line.strip)

      if enclosure_m
          enclosure = enclosure_m[1]
      end

      m = drive_pattern.match(line.strip)
      next if not m

      unit = m[4].strip
      _size = m[3]
      if unit == 'GB'
        _size = _size.to_i
      elsif unit == 'TB'
        _size = _size.to_f.round * 1024
      elsif unit == 'MB'
        _size = _size.to_i / 1024
      end

      if m[2] == 'Solid State SAS'
          iface_type = 'SSD'
      else
          iface_type = m[2]
      end

      response.push({
          'capacity' => _size,
          'iface_type' => iface_type,
          'slot' => m[1],
          'model' => '',
          'sn' => '',
          'enclosure' => enclosure,
        })
    end
  end
  return response
end

def ucsc_get_disk_metric()
    ret = []
    ret_list = []
    cmd = "storcli show ctrlcount J"
    output = Utils.facter_exec(cmd)
    ctrs_info = JSON.parse(output)['Controllers']
    # get conctolers count
    for ctr in ctrs_info
        if ctr.has_key?('Response Data') && ctr['Response Data'].has_key?('Controller Count')
            num_ctrs = ctr['Response Data']['Controller Count']
        else
            num_ctrs = -1
        end
    end

    for x in 0..num_ctrs-1
        output = `storcli /c#{x} show J`
        ctr_info = JSON.parse(output)['Controllers']
        for pd in ctr_info
            plist = pd['Response Data']['PD LIST']
            for p in plist
                p['EID:Slt'] = "#{x}:#{p['EID:Slt']}"
            end
        end
        ret = ret + plist
    end
    for r in  ret
        if r['Size'].include?("TB")
            r['Size'] = r['Size'].split(" ")[0].to_f*1000
        else 
            r['Size'] = r['Size'].split(" ")[0].to_f
        end
        ret_hash=Hash["capacity" => r['Size'],"model" => r['Model'].strip,"slot" => r['EID:Slt'],"iface_type"=>r['Intf']]
        ret_list = ret_list.push(ret_hash)
    end
    return ret_list
end

def disk_name_match(needle)
  pattern = ['sd', 'hd']
  pattern.each do |pt|
    return true if needle.start_with?(pt)
  end
  return false
end


Facter.add(:physical_disk_driver) do
  # only hp machine will use hpacucli to get disk information，
  # dell and cisco machine will get disk information by megacli
  # regardless if have a raid card or not，

  confine :kernel => 'Linux'
  setcode do

  response = []


  # have a raid card
  if Facter.value(:raid_adaptor_count).to_i > 0  # <= First
      if Facter.value(:manufacturer)  =~ /.*HP.*/i

          cli = Utils.hpacucli_for_linux
          cmd = "#{cli} ctrl all show config"
          response = hpcli_get_disk_metric(cmd) if File.exist?(cli)

      elsif Facter.value(:productname) == "UCSC-C240-M4L"
          response = ucsc_get_disk_metric
      
      else

        cli = Utils.megacli_for_linux
        cmd = "#{cli} -PDList -aALL -NoLog"
        #cmd = "#{cli} -PDList -aALL |grep -E '(Adapter|Slot|Raw Size|Inquiry|PD Type)'"

        response = megacli_get_disk_metric(cmd) if File.exist?(cli)
      end

  else   # <= First
    # have no raid card
      block_devices = Facter.value('blockdevices')
      block_devices_sequence = block_devices.split(',').select {|d| disk_name_match(d)}
      block_devices_sequence.each do |device_name|
        _d = {}
        _d['model'] = Facter.value("blockdevice_#{device_name}_model")
        _d['manufactory'] = Facter.value("blockdevice_#{device_name}_vendor")
        _d['capacity'] = Facter.value("blockdevice_#{device_name}_size").to_i / (1024**3) # unit: GB
        _d['sn'] = ''
        _d['slot'] = device_name
        _d['iface_type'] = ''
        _d['name'] = device_name
        _d['adaptor'] = ''
        response.push(_d)
      end

  end # <= First

  JSON.dump(response)
  end
end





Facter.add(:physical_disk_driver) do
  # Dell and cisco machine will get disk information by megacli，
  # other machine will use WMI，

  confine :kernel => 'windows'
  setcode do

    response = []

    # have a raid card
    if Facter.value(:raid_adaptor_count).to_i > 0  # <= First
        if Facter.value(:manufacturer)  =~ /.*HP.*/i
        # hp machine
          cli = Utils.hpacucli_for_win
          cmd = "#{cli} ctrl all show config"
          response = hpcli_get_disk_metric(cmd) if File.exist?(cli)
        else
          # Dell or UCS machine
          # Facter.value(:manufacturer)  =~ /.*(Dell|Cisco).*/i
          cli = Utils.megacli_for_win
          cmd = "#{cli} -PDList -aALL"

          response = megacli_get_disk_metric(cmd) if File.exist?(cli)
        end
    else # <= First
      # do not have raid card
        Facter::Util::WMI.execquery("select * from Win32_DiskDrive").each do | item |
          response.push(
              {
                'capacity' => item.size.to_i / (1024**3), # unite GB
                'iface_type' => item.InterfaceType,
                'slot' => item.Index,
                'model' => item.Model.strip,
                'sn' => item.SerialNumber.strip,
              }
          )

        end
    end # <= First
    JSON.dump(response)
  end
end


