# -*- encoding : utf-8 -*-

require 'rbconfig'

def win_sn
  output = `wmic bios get serialnumber /VALUE`
  sn = ''
  output.split("\n").each do |line|
    if line.start_with?("SerialNumber")
      sn = line.split("=")[1]
      break
    end
  end
  return sn
end

def linux_sn
  sn = ''
  output = `dmidecode -t 1|grep Serial`
  output.split("\n").each do |line|
    sn = line.split(":")[1].strip
    break
  end
  
  return sn
end


case RbConfig::CONFIG['host_os']
  when /cygwin|mswin|mingw|bccwin|wince|emx|windows/i
    puts win_sn
  when /linux|arch/i
    puts linux_sn
end

