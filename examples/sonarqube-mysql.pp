include ::java
class { '::mysql::server' : }
mysql::db { 'sonar' :
  user     => 'sonar',
  password => 'sonar',
  host     => 'localhost',
  grant    => ['ALL'],
}

class { '::sonarqube' :
  jdbc    => {
    url                               => 'jdbc:mysql://localhost/sonar?useUnicode=true&characterEncoding=utf8',
    username                          => 'sonar',
    password                          => 'sonar',
    max_active                        => '50',
    max_idle                          => '5',
    min_idle                          => '2',
    max_wait                          => '5000',
    min_evictable_idle_time_millis    => '600000',
    time_between_eviction_runs_millis => '30000',
  },
  require => Mysql::Db['sonar'],
}
