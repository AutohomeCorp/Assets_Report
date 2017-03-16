$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include?(File.dirname(__FILE__))
require "rubygems"
require 'json'
require 'utils'
#require_relative 'utils'

def mega_raid_type_pattern_match(needle)
  grep_pattern = ['RAID Level']
  grep_pattern.each do |pattern|
    return true if needle.start_with?(pattern)
  end
  return false
end

def mega_get_raid_type(cmd)

  response = []
  raid_type_result = Utils.facter_exec(cmd)

  if raid_type_result.strip.empty?
    return response
  else
    filted_raid_type_result = raid_type_result.split("\n").select do |line|
      mega_raid_type_pattern_match(line)
    end
  end
  filted_raid_type_result.each do |line|
    key, value = line.split(':')
    response.push(value.strip)
  end

  return response
end

def hpcli_get_raid_type(cmd)

    response = []

    raid_type_result = Utils.facter_exec(cmd)

    if not raid_type_result.empty?
      raid_type_result.split("\n").each do |line|
        m = line.match(/logicaldrive.*RAID.*/)
        response.push(m[0]) if m
      end
    end

    return response
end


Facter.add(:raid_type) do
  confine :kernel => 'Linux'
  setcode do

  response = []

  if Facter.value(:manufacturer) =~ /.*HP.*/i  # ---------

    cli = Utils.hpacucli_for_linux
    cmd = "#{cli} ctrl all show config"
    response = hpcli_get_raid_type(cmd)

  else # ---------

    cli = Utils.megacli_for_linux
    cmd = "#{cli} -LDInfo -Lall -aALL -Nolog"

    if File.exist?(cli)
      response = mega_get_raid_type(cmd)
    end
  end # ---------

  if response
    response.join(";")
  else
    ""
  end

  end
end

Facter.add(:raid_type) do
  confine :kernel => 'windows'
  setcode do

  response = []

  if Facter.value(:manufacturer) =~ /.*HP.*/i  # ---------
    cli = Utils.hpacucli_for_win
    cmd = "#{cli} ctrl all show config"
    response = hpcli_get_raid_type(cmd)

  else

    cli = Utils.megacli_for_win
    cmd = "#{cli}  -LDInfo -Lall -aALL"

    if File.exist?(cli)
      response = mega_get_raid_type(cmd)
    end
  end

  if response
    response.join(";")
  else
    ""
  end

  end
end


