require "rubygems"


Facter.add(:setuptime) do
  confine :kernel => 'Linux'
  setcode do
      setuptime_file = '/root/anaconda-ks.cfg'
      file = File.open(setuptime_file)

      if not File.exist?(setuptime_file)
        setuptime = ""
      else
        setuptime = file.stat.ctime.to_i
      end
    end
end

Facter.add(:setuptime) do
  confine :kernel => 'windows'
  setcode do

    setuptime_file = 'C:\Intel\Logs\IntelChipset.log'
    file = File.open(setuptime_file)

    if not File.exist?(setuptime_file)
      setuptime = ""
    else
      setuptime = file.stat.ctime.to_i 
    end
  end

end
