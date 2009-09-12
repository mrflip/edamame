class SinatraGod < GodProcess
  SinatraGod::DEFAULT_OPTIONS = {
    :monitor_group   => 'sinatras',
    :server_exe      => '/usr/bin/thin',        # path to thin. Override this in the site config file.
    :port            => 12000,
    :thin_config_yml => '/somedir/config.yml',
    :pid_file        => '/var/run/god/sinatra.pid'
  }
  def self.default_options() super.deep_merge(SinatraGod::DEFAULT_OPTIONS)           ; end
  def self.site_options()    super.deep_merge(global_site_options[:sinatra_god]||{}) ; end

  def self.kind
    :sinatra
  end

  def thin_command action
    [ options[:server_exe], action,
      "--config=#{options[:thin_config_yml]}",
      (options[:pid_file] ? "--pid=#{options[:pid_file]}" : ''),
    ].flatten.compact.join(" ")
  end

  def start_command
    thin_command :start
  end

  def restart_command
    thin_command :restart
  end

  def stop_command
    thin_command :stop
  end
end
