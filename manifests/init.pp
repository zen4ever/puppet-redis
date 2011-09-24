import "defines/*.pp"

class redis {
    user { "redis":
        ensure => present,
    }
    @service { "redis-server":
        ensure => running,
        enable => true,
        hasrestart => true,
        require => File["/etc/init.d/redis-server"],
    }
}
