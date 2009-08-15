class SinatraGod < GodProcess
  SinatraGod::CONFIG_DEFAULTS = {
    :port           => 12000,
    :app_dirname    => File.dirname(__FILE__)+'/../../app/edamame_san',
    :monitor_group  => 'sinatras',
    :server_exe     => '/usr/local/bin/shotgun',
  }
  def initialize *args
    super *args
    self.config = SinatraGod::CONFIG_DEFAULTS.compact.merge(self.config)
  end

  def self.kind
    :sinatra
  end

  def app_runner
    File.join(config[:app_dirname], config[:app_name] || 'config.ru')
  end

  def start_command
    [
      config[:server_exe],
      "--server=thin",
      "--port=#{config[:port]}",
      app_runner
    ].flatten.compact.join(" ")
  end
  # w.start   = "thin start   -C #{file} -o #{number}"
  # w.stop    = "thin stop    -C #{file} -o #{number}"
  # w.restart = "thin restart -C #{file} -o #{number}"

  def self.are_you_there_god_its_me_sinatra *args
    create *args
  end
end
