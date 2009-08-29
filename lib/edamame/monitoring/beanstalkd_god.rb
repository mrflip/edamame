class BeanstalkdGod < GodProcess
  BeanstalkdGod::CONFIG_DEFAULTS = {
    :listen_on      => '0.0.0.0',
    :port           => 11300,
    :user           => nil,
    :max_job_size   => '65535',
    :max_cpu_usage  => 50.percent,
    :max_mem_usage  => 500.megabytes,
    :monitor_group  => 'beanstalkds',
    :beanstalkd_exe => '/usr/local/bin/beanstalkd',
  }
  def initialize *args
    super *args
    self.config = BeanstalkdGod::CONFIG_DEFAULTS.compact.merge(self.config)
  end

  def self.kind
    :beanstalkd
  end

  def start_command
    [
      config[:beanstalkd_exe],
      "-l #{config[:listen_on]}",
      "-p #{config[:port]}",
      "-z #{config[:max_job_size]}",
      config[:user] ? "-u #{config[:user]}" : "",
    ].flatten.compact.join(" ")
  end

  def self.are_you_there_god_its_me_beanstalkd *args
    create *args
  end
end
