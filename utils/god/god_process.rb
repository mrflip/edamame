class GodProcess
  CONFIG_DEFAULTS = {
    :monitor_group      => nil,
    :uid                => nil,
    :gid                => nil,
    :start_notify       => nil,
    :restart_notify     => nil,
    :flapping_notify    => nil,

    :process_log_dir    => '/var/log/god',

    :start_grace_time   => 20.seconds,
    :restart_grace_time => nil,         # start_grace_time+2 if nil
    :default_interval   => 5.minutes,
    :start_interval     => 5.minutes,
    :mem_usage_interval => 20.minutes,
    :cpu_usage_interval => 20.minutes,
  }

  attr_accessor :config
  def initialize config
    self.config = CONFIG_DEFAULTS.compact.merge(config)
  end

  def setup
    LOG.info config.inspect
    God.watch do |watcher|
      config_watcher  watcher
      setup_start     watcher
      setup_restart   watcher
      setup_lifecycle watcher
    end
  end
  def self.create config={}
    proc = self.new config
    proc.setup
    proc
  end

  def handle
    (config[:handle] || "#{self.class.kind}_#{config[:port]}").to_s
  end

  def process_log_file
    File.join(config[:process_log_dir], handle+".log")
  end


  def mkdirs!
    require 'fileutils'
    FileUtils.mkdir_p File.dirname(process_log_file)
  end

  # command to start the daemon
  def start_command
    config[:start_command]
  end
  # command to stop the daemon
  # return nil to have god daemonize the process
  def stop_command
    config[:stop_command]
  end
  # command to restart
  # if stop_command is nil, it lets god daemonize the process
  # otherwise, by default it runs stop_command, pauses for 1 second, then runs start_command
  def restart_command
    return unless stop_command
    [stop_command, "sleep 1", start_command].join(" && ")
  end

  def config_watcher watcher
    watcher.name             = self.handle
    watcher.start            = start_command
    watcher.stop             = stop_command            if stop_command
    watcher.restart          = restart_command         if restart_command
    watcher.group            = config[:monitor_group]  if config[:monitor_group]
    watcher.uid              = config[:uid]            if config[:uid]
    watcher.gid              = config[:gid]            if config[:gid]
    watcher.interval         = config[:default_interval]
    watcher.start_grace      = config[:start_grace_time]
    watcher.restart_grace    = config[:restart_grace_time] || (config[:start_grace_time] + 2.seconds)
    watcher.behavior(:clean_pid_file)
  end

  #
  def setup_start watcher
    watcher.start_if do |start|
      start.condition(:process_running) do |c|
        c.interval = config[:start_interval]
        c.running  = false
        c.notify     = config[:start_notify] if config[:start_notify]
      end
    end
  end

  #
  def setup_restart watcher
    watcher.restart_if do |restart|
      restart.condition(:memory_usage) do |c|
        c.interval   = config[:mem_usage_interval] if config[:mem_usage_interval]
        c.above      = config[:max_mem_usage] || 150.megabytes
        c.times      = [3, 5] # 3 out of 5 intervals
        c.notify       = config[:restart_notify] if config[:restart_notify]
      end
      restart.condition(:cpu_usage) do |c|
        c.interval   = config[:cpu_usage_interval] if config[:cpu_usage_interval]
        c.above      = config[:max_cpu_usage] || 50.percent
        c.times      = 5
        c.notify       = config[:restart_notify] if config[:restart_notify]
      end
    end
  end

  # Define lifecycle
  def setup_lifecycle watcher
    watcher.lifecycle do |on|
      on.condition(:flapping) do |c|
        c.to_state     = [:start, :restart]
        c.times        = 10
        c.within       = 15.minute
        c.transition   = :unmonitored
        c.retry_in     = 60.minutes
        c.retry_times  = 5
        c.retry_within = 12.hours
        c.notify       = config[:flapping_notify] if config[:flapping_notify]
      end
    end
  end
end

class Hash
  # remove all key-value pairs where the value is nil
  def compact
    reject{|key,val| val.nil? }
  end
  # Replace the hash with its compacted self
  def compact!
    replace(compact)
  end
end
