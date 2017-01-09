$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include?(File.dirname(__FILE__))
require "rubygems"
require 'utils'

Facter.add(:cpu_core_count) do
  confine :kernel => 'Linux'
  setcode do
    Facter.value(:processorcount)
  end
end


Facter.add(:cpu_core_count) do
  confine :kernel => 'windows'
  setcode do

  cpu_core_count = 0

  require 'facter/util/wmi'
  cmd = 'wmic computersystem get NumberOfLogicalProcessors /VALUE'
  output = Utils.facter_exec(cmd)

  if not output.empty?
    output.split("\n").each do |line|
      strip_line = line.strip
      next if strip_line.empty?
      if strip_line.start_with?('NumberOfLogicalProcessors')
        key, value = strip_line.split('=')
        cpu_core_count = value.to_i
      end
    end

  end

  # for windows 2003 and below
  if 0 == cpu_core_count
    cpu_core_count = ENV['NUMBER_OF_PROCESSORS'].to_i
  end

  cpu_core_count
  end
end
