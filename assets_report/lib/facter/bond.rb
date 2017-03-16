$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include?(File.dirname(__FILE__))
require "rubygems"
require 'json'
require 'utils'

def bond_pattern_filter(content)
  result = []
  needle = 'Slave Interface'
  content.split("\n").each do |line|
    if line.start_with?(needle)
      result.push(line.split(':')[1].strip)
    end
  end
  return result
end

Facter.add(:bonding) do
  confine :kernel => 'Linux'
  setcode do

    bond_nic = Dir.glob('/proc/net/bonding/*')
    response = {}

    bond_nic.each do |bond_proc|
      bond_name = File.basename(bond_proc)
      nic_hardware = bond_pattern_filter(File.read(bond_proc))
      nic_hardware.each do |nic|
        response[nic] = bond_name
      end
    end

    JSON.dump(response)

  end
end
