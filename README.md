# puppet-module-nfsen

  A puppet module that installs/configures/manages nfsen.

## Parameters

```ruby
 $use_ramdisk::        Boolean. Mounts a ramdisk, uses the $profiledatadir for the 
                       base of the RAM disk. $profiledatadir must not be left default
                       and the directory must exist already (Puppet parent limitation).
 $ramdisk_size::       String. The size of the RAM disk if $use_ramdisk is true.

 $version::            String. Version of nfsen to install. Currently only '1.3.6p1'.

 nfsen parameters for nfsen.conf. All have defaults for nfsen.conf except $basedir
 $basedir::            String. Base directory for nfsen.
 $bindir::             String. Default '${BASEDIR}/bin'
 $libexecdir::         String. Default '${BASEDIR}/libexec'
 $confdir::            String. Default '${BASEDIR}/etc'
 $htmldir::            String. Default '/var/www/nfsen'
 $docdir::             String. Default '${BASEDIR}/doc'
 $vardir::             String. Default '${BASEDIR}/var'
 $piddir::             String. Default '${BASEDIR}/run'
 $filterdir::          String. Default '${BASEDIR}/filters'
 $formatdir::          String. Default '${BASEDIR}/fmt',
 $profilestatdir::     String. Default '${BASEDIR}/profiles-stat',
 $profiledatadir::     String. Default "#{BASEDIR}/profiles-data',
 $backend_plugindir::  String. Default "#{BASEDIR}/plugins',
 $frontend_plugindir:: String. Default "#{HTMLDIR}/plugins',
 $prefix::             String. Default '/usr/bin',
 $commsocket::         String. Default '${PIDDIR}/nfsen.comm',
 $user::               String. Default 'netflow',
 $wwwuser::            String. Default 'www-data'
 $wwwgroup::           String. Default 'www-group'
 $bufflen::            Integer. Default 200000 (bytes)
 $extensions::         String. Default 'all'
 $subdirlayout::       Integer. Default 2 (see nfdump/nfsen doc)
 $zipcollected::       Boolean. Default true
 $zipprofiles::        Boolean. Default true
 $profilers::          Integer. Default 2
 $disklimit::          Integer. Default 98
 $low_water::          Integer. Default 90
 $syslog_facility::    String. Default 'local3'
 $mail_from::          String. Default 'your@from.example.net'
 $mail_body::          String. Default 'q{ Alert \'@alert@\' triggered at timeslot @timeslot@ };'
 $sources::            Array of Hashes. See examples.
```

## Requires

puppet-module-nfdump ('nfdump') to be installed.

## Sample Usage:

Coming soon.

