import "defines/*.pp"

class redis {
    user { "redis":
        ensure => present,
    }
    redis_source {
        git: 
            version => "source",
            path => "/usr/src",
            owner => "redis",
            group => "redis",
            require => User["redis"],
    }
}
