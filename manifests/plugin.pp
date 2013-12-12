#
#
#
define jenkins::plugin(
    $version           = 0,
    $plugin            = "${name}.hpi",
    $plugin_parent_dir = '/var/lib/jenkins',
    $plugin_dir        = "$plugin_parent_dir/plugins",
  ) {

  if ($version != 0) {
    $base_url = "http://updates.jenkins-ci.org/download/plugins/${name}/${version}/"
    $search   = "${name} ${version},"
  }
  else {
    $base_url = 'http://updates.jenkins-ci.org/latest/'
    $search   = "${name} "
  }

  if( !defined(File[$plugin_parent_dir])) {
    file { $plugin_parent_dir:
        ensure  => directory,
        owner   => 'jenkins',
        group   => 'jenkins',
        require => [Group['jenkins'], User['jenkins']];
    }
  }

  if (!defined(File[$plugin_dir])) {
    file { $plugin_dir:
        ensure  => directory,
        owner   => 'jenkins',
        group   => 'jenkins',
        require => [Group['jenkins'], User['jenkins'], File[$plugin_parent_dir]];
    }
  }

  if (!defined(Group['jenkins'])) {
    group {
      'jenkins' :
        ensure  => present,
        require => Package['jenkins'];
    }
  }

  if (!defined(User['jenkins'])) {
    user {
      'jenkins' :
        ensure  => present,
        require => Package['jenkins'];
    }
  }

  if (!defined(Package['wget'])) {
    package {
      'wget' :
        ensure => present;
    }
  }

  if (empty(grep([ $::jenkins_plugins ], $search))) {
    exec {
      "download-${name}" :
        command    => "rm -rf ${name} ${name}.* && wget --no-check-certificate ${base_url}${plugin}",
        cwd        => $plugin_dir,
        require    => [File[$plugin_dir], Package['wget']],
        path       => ['/usr/bin', '/usr/sbin', '/bin'],
    }
  }

  file {
    "${plugin_dir}/${plugin}" :
      require => Exec["download-${name}"],
      owner   => 'jenkins',
      mode    => '0644',
      notify  => Service['jenkins'];
  }

}
