require "rubygems"

module Utils

  def self.get_facter_version
    version = Facter.value('facterversion')
    major = version.split('.')[0]
    return major.to_i
  end

  def self.facter_exec(cmd)
    result = ''
    if Utils.get_facter_version < 2
      result = Facter::Util::Resolution.exec(cmd)
    else
      result = Facter::Core::Execution.exec(cmd)
    end
    return result
  end

  def self.megacli_for_win
    if Facter.value(:architecture) == "x64"
      cli = 'C:\assets_report\MegaCli64.exe'
    else
      cli = 'C:\assets_report\MegaCli.exe'
    end
    return cli
  end

  def self.megacli_for_linux
      return '/opt/MegaRAID/MegaCli/MegaCli64'
  end

  def self.hpacucli_for_win
    return 'C:\assets_report\Compaq\Hpacucli\Bin\hpacucli.exe'
  end

  def self.hpacucli_for_linux

      hpssacli = '/opt/hp/hpssacli/bld/hpssacli'
      hpacucli = '/opt/compaq/hpacucli/bld/hpacucli'

      if File.exist?(hpssacli)
          return hpssacli
      else
          return hpacucli
      end

  end

end
