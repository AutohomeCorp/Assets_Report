class assets_report {

  if $kernel == 'windows' {

    file {'assets_report_files':
      path => 'C:\\assets_report',
      source => "puppet:///modules/assets_report/assets_report",
      ensure => directory,
      purge => true,
      source_permissions => ignore,
      recurse => true,
      owner => "Administrators",
      group => "Administrators",
    }

  } else {

    file {"assets_report_files":
      path => '/tmp/assets_report',
      source => "puppet:///modules/assets_report/assets_report",
      ensure => directory,
      recurse => true,
    }

    package {"MegaCli":
      provider => 'rpm',
      source => '/tmp/assets_report/MegaCli-8.07.10-1.noarch.rpm',
      ensure => installed,
      require => File['assets_report_files'],
      allow_virtual => false,
    }

   file {"/usr/bin/megacli":
      ensure => 'link',
      target => '/opt/MegaRAID/MegaCli/MegaCli64',
      require => Package['MegaCli'],
   }
    package {'hpacucli':
      provider => 'rpm',
      source => '/tmp/assets_report/hpacucli-9.40-12.0.x86_64.rpm',
      ensure => installed,
      require => File['assets_report_files'],
      allow_virtual => false,
      install_options => ['--force', '--nodeps'],
    }

    package {'hpssacli':
      provider => 'rpm',
      source   => '/tmp/assets_report/hpssacli-2.0-23.0.x86_64.rpm',
      ensure   => installed,
      require  => File['assets_report_files'],
      allow_virtual => false,
      install_options => ['--force', '--nodeps'],
    }
  }
}
