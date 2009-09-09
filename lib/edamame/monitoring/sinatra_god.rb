class SinatraGod < GodProcess
  SinatraGod::DEFAULT_OPTIONS = {
    :port            => 12000,
    :app_dirname     => File.dirname(__FILE__)+'/../../app/edamame_san',
    :monitor_group   => 'sinatras',
    :server_exe      => '/usr/bin/thin',
    :thin_config_yml => '/somedir/config.yml',
  }
  def initialize *args
    super SinatraGod::DEFAULT_OPTIONS.compact, *args
  end

  def self.kind
    :sinatra
  end

  def thin_command state
    [ options[:server_exe], state,
      "--config=#{options[:thin_config_yml]}"
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
