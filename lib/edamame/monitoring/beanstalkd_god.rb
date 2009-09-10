class BeanstalkdGod < GodProcess
  BeanstalkdGod::DEFAULT_OPTIONS = {
    :listen_on      => '0.0.0.0',
    :port           => 11300,
    :user           => nil,
    :max_job_size   => '65535',
    :max_cpu_usage  => 50.percent,
    :max_mem_usage  => 500.megabytes,
    :monitor_group  => 'beanstalkds',
    :beanstalkd_exe => '/usr/local/bin/beanstalkd',
  }
  def self.default_options() super.deep_merge(BeanstalkdGod::DEFAULT_OPTIONS)       ; end
  def self.site_options()    super.deep_merge(global_site_options[:beanstalkd_god]||{}) ; end

  def self.kind
    :beanstalkd
  end

  def start_command
    [
      options[:beanstalkd_exe],
      "-l #{options[:listen_on]}",
      "-p #{options[:port]}",
      "-z #{options[:max_job_size]}",
      options[:user] ? "-u #{options[:user]}" : "",
    ].flatten.compact.join(" ")
  end
end
