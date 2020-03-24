group { 'puppet':
  ensure => 'present'
}

class java_8::install {
#  exec { "update-package-list":
#    command => "/usr/bin/sudo /usr/bin/apt-get update",
#  }
  
  package { "openjdk-8-jdk":
    ensure => installed,
#    require => Exec["update-package-list"]
  }
}

include java_8::install

class h2 {
  include java_8::install
  
  exec { "create_schema":
    command => "/usr/bin/java -cp /vagrant/files/h2-1.3.172.jar org.h2.tools.RunScript -url jdbc:h2:~/todo -script /vagrant/files/todo-schema.sql",
    user => 'vagrant',
    creates => "/home/vagrant/todo.h2.db"
  }
}

include h2

Class["java_8::install"] -> Class["h2"]

class tomcat8::prereqs {
  if !defined(Group['vagrant']) {
    group { "vagrant" :
      ensure => "present"
    }
  }

  if !defined(User['vagrant']) {
    user { "vagrant" :
      ensure => "present",
      gid => "vagrant",
      managehome => true,
      require => Group['vagrant']
    }
  }
}

class tomcat8 {
  include tomcat8::prereqs
  $tomcat_version = "8.5.15"
  $tomcat_name = "apache-tomcat-${tomcat_version}"
  $tomcat_download_url = "http://archive.apache.org/dist/tomcat/tomcat-8/v${tomcat_version}/bin/${tomcat_name}.tar.gz"
  $tomcat_install_dir = "/home/vagrant/${tomcat_name}"

  exec {
    "download_tomcat8":
      cwd => "/tmp",
      command => "/usr/bin/wget http://archive.apache.org/dist/tomcat/tomcat-8/v8.5.15/bin/apache-tomcat-8.5.15.tar.gz",
      creates => "/tmp/apache-tomcat-8.5.15.tar.gz";

    "unpack_tomcat8":
      cwd => "/home/vagrant",
      command => "/bin/tar -zxf /tmp/apache-tomcat-8.5.15.tar.gz",
      creates => "/home/vagrant/apache-tomcat-8.5.15",
      require => Exec["download_tomcat8"]
  }

  file { "/home/vagrant/apache-tomcat-8.5.15":
    recurse => true,
    owner => 'vagrant',
    group => 'vagrant',
    require => [ Exec['unpack_tomcat8'], Class['tomcat8::prereqs'] ]
  }

  exec {
    "start_tomcat8":
      command => "/home/vagrant/apache-tomcat-8.5.15/bin/startup.sh",
      user => "vagrant"
  }


  
#  service { 'tomcat':
#    provider => "init",
#    ensure => running,
#    start => "/home/vagrant/apache-tomcat-8.5.15/bin/startup.sh",
#    stop => "/home/vagrant/apache-tomcat-8.5.15/bin/shutdown.sh",
#    status => "",
#    restart => "",
#    hasstatus => false,
#    hasrestart => false,
#    require => [ Exec['unpack_tomcat8'], Class['tomcat8::prereqs'] ],
#  }
  
#  file { "/home/vagrant/apache-tomcat-8.5.15/conf/tomcat-users.xml": 
#    owner => 'tomcat',
#    group => 'tomcat',
#    source => "/vagrant/files/tomcat-users.xml",
#    notify => Service['tomcat'],
#    require => [ Exec['unpack_tomcat8'], Class['tomcat8::prereqs'] ]
#  }
}

include tomcat8

Class["java_8::install"] -> Class["tomcat8"]
