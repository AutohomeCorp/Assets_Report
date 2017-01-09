$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include?(File.dirname(__FILE__))
require "rubygems"
require 'json'
#require_relative 'utils'
require 'utils'

def hpcli_get_raid_adaptor_count(cmd)
    response = 0
    output = Utils.facter_exec(cmd)
    if not output.empty?
      output.split("\n").each do |line|
        m = line.match(/Smart Array.*Slot.*/)
        response += 1 if m
      end
    end
    return response
end

Facter.add(:raid_adaptor_count) do
  confine :kernel => 'Linux'
  setcode do

  response = 0

  if Facter.value(:manufacturer)  =~ /.*HP.*/i
      cli = Utils.hpacucli_for_linux
      cmd = "#{cli} ctrl all show config"
      response = hpcli_get_raid_adaptor_count(cmd) if File.exist?(cli)
  else

    cli = Utils.megacli_for_linux
    cmd = "#{cli} -adpCount -Nolog|grep Controller"

    if File.exist?(cli)
      result = Utils.facter_exec(cmd)
      if not result.strip.empty?
        key, value = result.split(":")
        response = value.strip.chomp('.')
      end
    end

  end

  response
  end
end


Facter.add(:raid_adaptor_count) do
  confine :kernel => 'windows'

  setcode do

    response = 0

    if Facter.value(:manufacturer)  =~ /.*HP.*/i
      cli = Utils.hpacucli_for_win
      cmd = "#{cli} ctrl all show config"
      response = hpcli_get_raid_adaptor_count(cmd) if File.exist?(cli)

    else

      cli = Utils.megacli_for_win
      cmd = "#{cli} -adpCount"
      if File.exist?(cli)
        result = Utils.facter_exec(cmd)
        if not result.strip.empty?
          result.split("\n").each do |line|
            next if line.strip.empty?
            key, value = line.split(":")

            next unless key.strip == "Controller Count"
            response = value.strip.chomp('.')
            break
          end
        end
      end
    end
    response
  end
end

