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
  module JobCore

    def key
      [ tube, obj[:key]||obj['key'] ].join('-')
    end

    #
    def since_last
      scheduling.last_run - Time.now
    end

    # Beanstalk::Job stats:
    #    { "pri"=>65536, "ttr"=>120,
    #    {"releases"=>8, "delay"=>5, "kicks"=>0, "buries"=>0, "id"=>202,
    #     "tube"=>"default", "time-left"=>120,
    #     "timeouts"=>0, "age"=>1415, "state"=>"reserved"}
    #
    #    [ "id",
    #      "tube", "pri", "ttr", "state",
    #      "delay",
    #      "releases", "kicks", "buries",
    #      "time-left", "timeouts", "age", ]
  end


  Beanstalk::Job.class_eval do
    include JobCore

    def scheduling
      @scheduling ||= Edamame::Scheduling.from_hash ybody['scheduling']
    end

    def obj
      ybody['obj']
    end

    def priority
      pri
    end

    def tube
      stats['tube']
    end

    # Override this for rescheduling
    def update!
      scheduling.total_runs = scheduling.total_runs.to_i + stats['releases']
      scheduling.last_run   = Time.now
    end

    def to_hash flatten=true
      hsh =       {
        "tube"       => tube,
        "priority"   => priority,
        "ttr"        => ttr,
        "state"      => state,
        "scheduling" => scheduling.to_hash,
        'key'        => key,
        "obj"        => obj.to_hash,
      }
      if flatten
        hsh["scheduling"] = hsh['scheduling'].to_yaml
        hsh["obj"]        = hsh['obj'].to_yaml
      end
      hsh
    end
  end

  class Job < Struct.new(
    :tube, :priority, :ttr, :state,
    :scheduling, :obj
    )
    # Job.class_eval do
    include JobCore

    DEFAULT_OPTIONS = {
      'priority'   => 65536,
      'ttr'        => 120,
      'state'      => 1,
      'scheduling' => Edamame::Scheduling::Once.new()
    }

    # attr_accessor :runs, :failures, :prev_run_at
    def initialize *args
      super *args
      DEFAULT_OPTIONS.each{|key,val| self[key] ||= val }
      [:priority, :ttr, :state].each{|key| self[key] = self[key].to_i }
      case self.scheduling
      when String
        scheduling_hash = YAML.load(self.scheduling) rescue nil
        self.scheduling = Scheduling.from_hash(scheduling_hash) if scheduling_hash
      when Hash
        self.scheduling = Scheduling.from_hash(scheduling)
      else raise "Can't build a Scheduling from #{self.scheduling}" ;  end
      if self.obj.is_a?(String)        then self.obj        = YAML.load(self.obj)        rescue nil ; end
    end

    def delay
      scheduling.delay
    end

    def to_hash flatten=true
      hsh = super()
      hsh["scheduling"] = scheduling.to_hash
      hsh["obj"]        = obj.to_hash
      if flatten
        hsh["scheduling"] = hsh['scheduling'].to_yaml
        hsh["obj"]        = hsh['obj'].to_yaml
      end
      hsh
    end
  end
end


