module God
  #
  # Given a base port number and an associative array
  #   [ [GodProcessSubclass, { :options => 'for factory methods', ... }],
  #     ..., }
  # this creates each given service with incrementing port numbers.
  #
  # For example,
  #
  #     God.service_group 12300, [
  #       [BeanstalkdGod, { :max_mem_usage => 2.gigabytes,  }],
  #       [TyrantGod,     { :db_dirname => EDAMAME_DB_DIR, :db_name => 'queue_jobs.tch' }],
  #       [TyrantGod,     { :db_dirname => EDAMAME_DB_DIR, :db_name => 'fetched_urls.tch' }],
  #       [ThinGod,       { :thin_config_yml => '/slice/www/edamame_monitor/current/config.yml' }],
  #       ]
  #
  # will create an edamame pair of beanstalkd queue on 123000 and tyrant DB on
  # 12301, an app-specific DB on 12302, and a lightweight monitoring web app on
  # 12303.
  #
  # It's up to you to choose the ports to not overlap with other groups, etc.
  #
  # If an explicit port is given, that port is used with no regard to the rest
  # of the group, and its number is skipped.
  #
  def self.process_group base_port, services
    services.each do |klass, options|
      klass.create({ :port => base_port }.deep_merge(options))
      base_port += 1
    end
  end
end
