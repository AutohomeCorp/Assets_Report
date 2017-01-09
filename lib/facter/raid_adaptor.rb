$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include?(File.dirname(__FILE__))
require "rubygems"
require 'json'
#require_relative 'utils'
require 'utils'

def merge_response(left, right)
  response = {}
  left.each do |k, v|
    response[k] = left[k].merge(right[k]) if right.has_key?(k)
  end
  return response
end


def mega_raid_pattern_match(needle)
  grep_pattern = ['Product Name', 'Serial No', 'Memory Size']
  grep_pattern.each do |pattern|
    return true if needle.start_with?(pattern)
  end
  return false
end



def mega_get_raid_adaptor(cmd)

  key_map = {
    'Product Name' => 'model',
    'Serial No' => 'sn',
    'Memory Size' => 'memory_size',
  }

  response = {}
  pair_sequence = []

  metric_from_megacli = Utils.facter_exec(cmd)

  if metric_from_megacli.strip.empty?
    return {}
  else
    filted_raid_result = metric_from_megacli.split("\n").select do |line|
      mega_raid_pattern_match(line)
    end
  end

  if filted_raid_result.empty?
    return {}
  end

  filted_raid_result.each do |line|
    key, value = line.split(':')
    pair_sequence.push([key.strip, value.strip])
  end

  first_flag = pair_sequence[0][0]

  element = {}
  adaptor_count = -1
  pair_sequence_size =  pair_sequence.size()
  pair_sequence.each_with_index do |pair, idx|
    key, value = pair

    next if not key_map.has_key?(key.strip)

    if key == first_flag
      element[key_map[key]] = value
    elsif (idx+1) == pair_sequence_size or pair_sequence[idx+1][0] == first_flag
      element[key_map[key]] = value
      adaptor_count += 1
      response['adaptor_' << adaptor_count.to_s] = element
      element = {}
    else
      element[key_map[key]] = value
    end

  end

  return response
end


def hpcli_get_raid_adaptor(cmd)

  response = {}
  output = Utils.facter_exec(cmd)

  if not output.empty?
    idx = -1
    output.split("\n").each do |line|
      m = /^(Smart Array.*)in Slot.*sn:(.*)$/.match(line)
      next if not m
      response["adaptor_#{idx+1}"] = {
          'memory_size' => 0,
          'model' => m[1].strip,
          'sn' => m[2].strip,
        }

    end
  end
  return response
end


Facter.add(:raid_adaptor) do
  confine :kernel => 'Linux'
  setcode do

    response = {}

    if Facter.value(:manufacturer)  =~ /.*HP.*/i  # ----------------
      cli = Utils.hpacucli_for_linux
      cmd = "#{cli} ctrl all show config"

      if File.exist?(cli)
        response = hpcli_get_raid_adaptor(cmd)
      end

    else # ----------------

      cli = Utils.megacli_for_linux
      cmd = "#{cli} -AdpAllInfo -aALL -Nolog"
      if File.exist?(cli)
        response = mega_get_raid_adaptor(cmd)
      end

    end  # ----------------

    JSON.dump(response)
  end
end


Facter.add(:raid_adaptor) do
  confine :kernel => 'windows'
  setcode do

    response = {}

    if Facter.value(:manufacturer)  =~ /.*HP.*/i  # ----------------
      cli = Utils.hpacucli_for_win
      cmd = "#{cli} ctrl all show config"

      if File.exist?(cli)
        response = hpcli_get_raid_adaptor(cmd)
      end

    else  # ----------------
      cli = Utils.megacli_for_win
      cmd = "#{cli} -AdpAllInfo -aALL"

      if File.exist?(cli)
        response = mega_get_raid_adaptor(cmd)
      end
    end  # ----------------

    JSON.dump(response)

  end
end

