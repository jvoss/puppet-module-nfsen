# = Class: nfsen
#
# This class installs/configures/manages nfsen.
#
# == Parameters:
#
# $use_ramdisk::        Boolean. Mounts a ramdisk, uses the $profiledatadir for the 
#                       base of the RAM disk. $profiledatadir must not be left default
#                       and the directory must exist already (Puppet parent limitation).
# $ramdisk_size::       String. The size of the RAM disk if $use_ramdisk is true.
#
# $version::            String. Version of nfsen to install. Currently only '1.3.6p1'.
#
# nfsen parameters for nfsen.conf. All have defaults for nfsen.conf except $basedir
# $basedir::            String. Base directory for nfsen.
# $bindir::             String. Default '${BASEDIR}/bin'
# $libexecdir::         String. Default '${BASEDIR}/libexec'
# $confdir::            String. Default '${BASEDIR}/etc'
# $htmldir::            String. Default '/var/www/nfsen'
# $docdir::             String. Default '${BASEDIR}/doc'
# $vardir::             String. Default '${BASEDIR}/var'
# $piddir::             String. Default '${BASEDIR}/run'
# $filterdir::          String. Default '${BASEDIR}/filters'
# $formatdir::          String. Default '${BASEDIR}/fmt',
# $profilestatdir::     String. Default '${BASEDIR}/profiles-stat',
# $profiledatadir::     String. Default "#{BASEDIR}/profiles-data',
# $backend_plugindir::  String. Default "#{BASEDIR}/plugins',
# $frontend_plugindir:: String. Default "#{HTMLDIR}/plugins',
# $prefix::             String. Default '/usr/bin',
# $commsocket::         String. Default '${PIDDIR}/nfsen.comm',
# $user::               String. Default 'netflow',
# $wwwuser::            String. Default 'www-data'
# $wwwgroup::           String. Default 'www-group'
# $bufflen::            Integer. Default 200000 (bytes)
# $extensions::         String. Default 'all'
# $subdirlayout::       Integer. Default 2 (see nfdump/nfsen doc)
# $zipcollected::       Boolean. Default true
# $zipprofiles::        Boolean. Default true
# $profilers::          Integer. Default 2
# $disklimit::          Integer. Default 98
# $low_water::		Integer. Default 90
# $syslog_facility::    String. Default 'local3'
# $mail_from::          String. Default 'your@from.example.net'
# $mail_body::          String. Default 'q{ Alert \'@alert@\' triggered at timeslot @timeslot@ };'
# $sources::            Array of Hashes. See examples.
#
# == Requires:
#
# puppet-module-nfdump ('nfdump') to be installed.
#
# == Sample Usage:
#
class nfsen ( $use_ramdisk        = false,
              $ramdisk_size       = '0M',
              $version            = '1.3.6p1',
              $basedir            = '/tmp/testing',
              $bindir             = '${BASEDIR}/bin',
              $libexecdir         = '${BASEDIR}/libexec',
              $confdir            = '${BASEDIR}/etc',
              $htmldir            = '/var/www/nfsen/',
              $docdir             = '${BASEDIR}/doc',
              $vardir             = '${BASEDIR}/var',
              $piddir             = '${BASEDIR}/run',
              $filterdir          = '${VARDIR}/filters',
              $formatdir          = '${VARDIR}/fmt',
              $profilestatdir     = '${BASEDIR}/profiles-stat',
              $profiledatadir     = '${BASEDIR}/profiles-data',
              $backend_plugindir  = '${BASEDIR}/plugins',
              $frontend_plugindir = '${HTMLDIR}/plugins',
              $prefix             = '/usr/bin',
              $commsocket         = '${PIDDIR}/nfsen.comm',
              $user               = 'netflow',
              $wwwuser            = 'www-data',
              $wwwgroup           = 'www-data',
              $bufflen            = 200000,
              $extensions         = 'all',
              $subdirlayout       = 2,
              $zipcollected       = true,
              $zipprofiles        = true,
              $profilers          = 2,
              $disklimit          = 98,
              $low_water          = 90,
              $syslog_facility    = 'local3',
              $mail_from          = 'your@from.example.net',
              $smtp_server        = 'localhost',
              $mail_body          = 'q{ Alert \'@alert@\' triggered at timeslot @timeslot@ };',
              $sources            = [ {name => 'all', port => '9995', col => '#0000ff', type => 'netflow'} ]
            ) 
{

  case $operatingsystem {

    ubuntu: {

      if $use_ramdisk {
        file { $profiledatadir:
          before  => Exec['install'],
          ensure  => 'directory',
        }
                
        mount { $profiledatadir:
          atboot  => true,
          before  => Service['nfsen'],
          device  => 'ramdisk',
          ensure  => 'mounted',
          fstype  => 'tmpfs',
          options => "nodev,nosuid,size=$ramdisk_size",
          require => File[$profiledatadir]
        }
      }

      exec { 'install':
        before    => Service['nfsen'],
        command   => 'install.pl /opt/nfsen/etc/nfsen.conf',
        cwd       => '/opt/nfsen',
        logoutput => 'on_failure',
        onlyif    => "test ! -d $basedir || test ! -d $htmldir",
        path      => '/usr/bin:/opt/nfsen',
        require   => [ File['/opt/nfsen/etc/nfsen.conf'], User[$user] ]
      }

      exec { 'nfsen-reconfig':
        command     => 'nfsen reconfig',
        path        => "/usr/bin:$basedir/bin",
        refreshonly => true,
        subscribe   => File["$basedir/etc/nfsen.conf"]
      }

      file { "$basedir/etc/nfsen.conf":
        before  => Service['nfsen'],
        content => template('nfsen/nfsen.conf.erb'),
        ensure  => file,
        require => Exec['install']
      }

      file { '/opt/nfsen':
        ensure  => 'directory',
        recurse => true,
        require => [ Package['perl'], Package['php5'], Package['rrdtool'] ],
        source  => "puppet:///modules/nfsen/nfsen-$version",
      }

      file { '/opt/nfsen/etc/nfsen.conf':
        content => template('nfsen/nfsen.conf.erb'),
        ensure  => file,
        require => File['/opt/nfsen']
      }

      file { "$htmldir/index.php":
        ensure  => 'link',
        require => Exec['install'],
        target  => "$htmldir/nfsen.php"
      }

      package { 'libmailtools-perl':
        ensure  => 'installed'
      }

      package { 'librrds-perl':
        ensure  => 'installed'
      }

      package { 'perl':
        before  => [ Package['libmailtools-perl'], Package['librrds-perl'] ],
        ensure  => 'installed'
      }

      package { 'php5':
        ensure  => 'installed'
      }

      package { 'rrdtool':
        ensure  => 'installed'
      }

      service { 'nfsen':
        ensure    => 'running',
        hasstatus => false,
        path      => "$basedir/bin",
        pattern   => "$basedir/bin/nfsend"
      }

      user { $user:
        ensure  => 'present',
        groups  => $wwwgroup,
        before  => Exec['install']
      }

    } # ubuntu

  } # case $operatingsystem

}
