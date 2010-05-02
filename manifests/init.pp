import "defines/*.pp"

class redis {
    redis_source {
        git: 
            version => "source",
            path => "/usr/src",
    }
    file { "/etc/redis.conf":
        ensure => present,
        source => "puppet:///modules/redis/redis.conf",
        replace => false;
    }

}
#Exec { path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" }
#include redis
