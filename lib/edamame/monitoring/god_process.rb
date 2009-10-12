class GodProcess
  DEFAULT_OPTIONS = {
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
  # Site options definition files. Merged in order, later entries win.
  GLOBAL_SITE_OPTIONS_FILES = []
  # merged contents of the GLOBAL_SITE_OPTIONS_FILES
  cattr_reader  :global_site_options
  attr_accessor :options

  #
  # * Class options are defined by the edamame code. They define each process'
  #   base behavior.
  #
  # * Site options are defined by config file(s), and define machine/org
  #   specific policy (paths to daemon executables, for instance). Site options
  #   override class options.
  #
  # * Options passed in at instantiation describe the specifics of this
  #   particular process -- the path to a database's file, perhaps. They
  #   override site options (and therefore class options too).
  #
  # Note that, though the options hash is preserved, if action
  #
  def initialize _options
    self.options = { }
    self.options.deep_merge! self.class.default_options
    self.options.deep_merge! self.class.site_options
    self.options.deep_merge! _options
    p self.options
  end

  #
  # Walks upwards through the inheritance tree, accumulating default
  # options. Later (subclass) nodes should override earlier (super) nodes, with
  # something like
  #
  #     def self.default_options
  #       super.deep_merge(ThisClass::DEFAULT_OPTIONS)
  #     end
  #
  def self.default_options
    GodProcess::DEFAULT_OPTIONS
  end

  #
  # Walks upwards through the inheritance tree, accumulating site
  # options. Later (subclass) nodes should override earlier (super) nodes, with
  # something like
  #
  #     def self.site_options
  #       super.deep_merge( global_site_options[:this_class] )
  #     end
  #
  def self.site_options
    global_site_options[:god_process] || {}
  end

  def self.global_site_options
    return @global_site_options if @globalsite_options
    @global_site_options = {}
    GLOBAL_SITE_OPTIONS_FILES.each do |options_filename|
      @global_site_options.deep_merge! YAML.load_file(options_filename)
    end
    @global_site_options
  end

  def setup
    LOG.info options.inspect
    God.watch do |watcher|
      setup_watcher   watcher
      setup_start     watcher
      setup_restart   watcher
      setup_lifecycle watcher
    end
  end
  def self.create options={}
    proc = self.new options
    proc.setup
    proc.mkdirs!
    proc
  end

  def handle
    (options[:handle] || "#{self.class.kind}_#{options[:port]}").to_s
  end

  # Log file
  def process_log_file
    File.join(options[:process_log_dir], handle+".log")
  end

  # create any directories required by the process
  def mkdirs!
    require 'fileutils'
    FileUtils.mkdir_p File.dirname(process_log_file)
  end

  # command to start the daemon
  def start_command
    options[:start_command]
  end
  # command to stop the daemon
  # return nil to have god daemonize the process
  def stop_command
    options[:stop_command]
  end
  # command to restart
  # if stop_command is nil, it lets god daemonize the process
  # otherwise, by default it runs stop_command, pauses for 1 second, then runs start_command
  def restart_command
    return unless stop_command
    [stop_command, "sleep 1", start_command].join(" && ")
  end

  #
  # Setup common to most watchers
  #
  def setup_watcher watcher
    watcher.name             = self.handle
    watcher.start            = start_command
    watcher.stop             = stop_command             if stop_command
    watcher.restart          = restart_command          if restart_command
    watcher.group            = options[:monitor_group]  if options[:monitor_group]
    watcher.uid              = options[:uid]            if options[:uid]
    watcher.gid              = options[:gid]            if options[:gid]
    watcher.pid_file         = options[:pid_file]       if options[:pid_file]
    watcher.interval         = options[:default_interval]
    watcher.start_grace      = options[:start_grace_time]
    watcher.restart_grace    = options[:restart_grace_time] || (options[:start_grace_time] + 2.seconds)
    watcher.behavior(:clean_pid_file)
  end

  #
  # Starts process
  #
  def setup_start watcher
    watcher.start_if do |start|
      start.condition(:process_running) do |c|
        c.interval = options[:start_interval]
        c.running  = false
        c.notify     = options[:start_notify] if options[:start_notify]
      end
    end
  end

  #
  def setup_restart watcher
    watcher.restart_if do |restart|
      restart.condition(:memory_usage) do |c|
        c.interval   = options[:mem_usage_interval] if options[:mem_usage_interval]
        c.above      = options[:max_mem_usage] || 150.megabytes
        c.times      = [3, 5] # 3 out of 5 intervals
        c.notify     = options[:restart_notify] if options[:restart_notify]
      end
      restart.condition(:cpu_usage) do |c|
        c.interval   = options[:cpu_usage_interval] if options[:cpu_usage_interval]
        c.above      = options[:max_cpu_usage] || 50.percent
        c.times      = 5
        c.notify     = options[:restart_notify] if options[:restart_notify]
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
        c.notify       = options[:flapping_notify] if options[:flapping_notify]
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
