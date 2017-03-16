$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include?(File.dirname(__FILE__))
require "rubygems"
require 'pp'
require 'json'
require 'utils'

def dmi_get_ram(cmd)

    ram_slot = []

    key_map = {
        'Size' => 'capacity',
        'Serial Number' => 'sn',
        'Type' => 'model',
        'Manufacturer' => 'manufactory',
        'Locator' => 'slot',
    }

    output = Utils.facter_exec(cmd)
    devices = output.split('Memory Device')

    devices.each do |d|
      next if d.strip.empty?
      segment = {}
      d.strip.split("\n\t").each do |line|
        key, value = line.strip.split(":")
        if key_map.has_key?(key.strip)
          if key.strip == 'Size'
            if value.include?("MB")
              segment[key_map['Size']] = value.chomp("MB").strip.to_i / 1024.0 # unit GB
            else
              segment[key_map['Size']] = value.chomp("GB").strip.to_i # unit GB
            end
          else
            segment[key_map[key.strip]] =  value ? value.strip : ''
          end
        end
      end

      ram_slot.push(segment) unless segment.empty?
    end

    return ram_slot

end

Facter.add("ram") do
  confine :kernel => "Linux"
  setcode do

    ram_slot = []
    cmd = "dmidecode -q -t 17 2>/dev/null"
    ram_slot = dmi_get_ram(cmd)

    JSON.dump(ram_slot)

  end
end


Facter.add("ram") do
  confine :kernel => 'windows'
  setcode do

    ram_slot = []

    if Facter.value(:manufacturer)  =~ /.*HP.*/i
      cli = 'C:\assets_report\dmidecode.exe'
      cmd = "#{cli} -q -t 17"
      ram_slot = dmi_get_ram(cmd) if File.exist?(cli)

    else

      require 'facter/util/wmi'
      Facter::Util::WMI.execquery("select * from Win32_PhysicalMemory").each do | item |

        if item.DeviceLocator
          slot = item.DeviceLocator.strip
        else
          slot = ''
        end

        if item.PartNumber
          model = item.PartNumber.strip
        else
          model = ''
        end

        if item.SerialNumber
          sn = item.SerialNumber.strip
        else
          sn = ''
        end

        if item.Manufacturer
          manufactory = item.Manufacturer.strip
        else
          manufactory = ''
        end

        ram_slot.push({
         'capacity' => item.Capacity.to_i / (1024**3), # unit GB
         'slot' => slot,
         'model' => model,
         'sn' => sn,
         'manufactory' => manufactory,
       })

      end
    end

    JSON.dump(ram_slot)

  end
end
