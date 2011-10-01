define redis::source(
    $version = '2.2.14',
    $path = '/usr/local/src',
    $bin = '/usr/local/bin',
    $owner = 'redis',
    $redis_timeout = "0",
    $group = 'redis'
) {
    case $version {
        default: {
             file { redis_folder:
                 path => "${path}/redis_${version}",
                 ensure => "directory",
                 owner => root,
                 group => root
             }
             exec { redis_code: 
                  command =>"wget http://github.com/antirez/redis/tarball/${version} -O redis_${version}.tar.gz && tar --strip-components 1 -xzvf redis_${version}.tar.gz",
                  cwd => "${path}/redis_${version}",
                  creates => "${path}/redis_${version}/src/redis.c",
                  require => File["redis_folder"],
                  before => Exec["make ${version}"]
             }
             file { "${path}/redis_${version}/redis_${version}.tar.gz":
                  ensure => absent,
                  require => Exec["redis_code"]
             }

        }
        source: {
             exec { "git clone git://github.com/antirez/redis.git redis_${version}":
                 cwd => "${path}",
                 creates => "${path}/redis_${version}/.git/HEAD",
                 before => Exec["make ${version}"]
             }
        }
    }
    exec { "make ${version}":
         cwd => "${path}/redis_${version}",
         command => "make && mv src/redis-server ${bin}/ && mv src/redis-cli ${bin}/ && mv src/redis-benchmark ${bin}/ && mv src/redis-check-dump ${bin}/",
         creates => "${bin}/redis-server",
    }
    file { db_folder:
        path => "/var/lib/redis",
        ensure => "directory",
        owner => $owner,
        group => $group,
        require => Exec["make ${version}"],
    }
    file { "/etc/init.d/redis-server":
         content => template("redis/redis-server.erb"),
         owner => root,
         group => root,
         mode => 744,
         require => [File["/etc/redis.conf"], File["db_folder"]],
         notify => Service["redis-server"],
    }
    file { "/etc/redis.conf":
        ensure => present,
        content => template("redis/redis.conf.erb"),
        notify => Service["redis-server"];
    }
    realize Service["redis-server"]
}
