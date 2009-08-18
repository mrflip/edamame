module Edamame
  #
  #
  # id, name, body, timeouts, time-left, age, state, delay, pri, ttr
  #
  #
  # * A job, pulled from the queue: it is connected to its beanstalk presence
  #   body contains
  #   ** obj
  #   ** scheduling
  #   ** stats
  #
  # * A DB job
  #   body contains
  #   ** tube, priority, ttr, state
  #   ** obj
  #   ** scheduling
  #   ** stats

  Beanstalk::Job.class_eval do
    def scheduling
      @scheduling ||= Edamame::Scheduling.from_hash ybody['scheduling']
    end

    def obj
      ybody['obj']
    end

    def key
      [tube, obj[:key]].join('-')
    end

    def priority
      pri
    end

    def tube
      stats['tube']
    end

    def to_hash flatten=true
      hsh =       {
        "tube"       => tube,
        "priority"   => priority,
        "ttr"        => ttr,
        "state"      => state,
        "stats"      => stats.to_hash,
        "scheduling" => scheduling.to_hash.merge('type'=>scheduling.class.to_s.gsub(/Edamame::Scheduling::/,'')),
        'key'        => key,
        "obj"        => obj.to_hash,
      }
      if flatten
        hsh["scheduling"] = hsh['scheduling'].to_yaml
        hsh["stats"]      = hsh['stats'].to_yaml
        hsh["obj"]        = hsh['obj'].to_yaml
      end
      hsh
    end
  end

  Job = Struct.new(
    :tube, :priority, :ttr, :state,
    :stats, :scheduling, :obj
    )

  Job.class_eval do
    # attr_accessor :runs, :failures, :prev_run_at
    def initialize *args
      super *args
      [:priority, :ttr, :state].each{|k| self[k] = self[k].to_i }
      if self.stats.is_a?(String)      then self.stats      = YAML.load(self.stats)      rescue nil ; end
      case self.scheduling
      when String
        scheduling_hash = YAML.load(self.scheduling) rescue nil
        self.scheduling = Scheduling.from_hash(scheduling_hash) if scheduling_hash
      when Hash
        self.scheduling = Scheduling.from_hash(scheduling)
      end
      if self.obj.is_a?(String)        then self.obj        = YAML.load(self.obj)        rescue nil ; end
    end

    # Override this for rescheduling
    def update!
    end

    def delay
      scheduling.delay
    end

    def key
      [tube, obj[:key]].join('-')
    end

    def to_hash flatten=true
      hsh = super()
      hsh["scheduling"] = scheduling.to_hash.merge('type'=>scheduling.class.to_s.gsub(/Edamame::Scheduling::/,''))
      hsh["stats"]      = stats.to_hash
      hsh["obj"]        = obj.to_hash
      if flatten
        hsh["scheduling"] = hsh['scheduling'].to_yaml
        hsh["stats"]      = hsh['stats'].to_yaml
        hsh["obj"]        = hsh['obj'].to_yaml
      end
      hsh
    end
  end
end


