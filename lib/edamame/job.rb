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
  class Job < Struct.new(
    :tube, :priority, :ttr, :state,
    :scheduling, :obj
      )
    # connection back to the job queue's instance of this job
    attr_accessor :qjob

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
      p ['job born', args, self.scheduling]
      case self.scheduling
      when String
        scheduling_hash = YAML.load(self.scheduling) rescue nil
        self.scheduling = Scheduling.from_hash(scheduling_hash) if scheduling_hash
      when Hash
        self.scheduling = Scheduling.from_hash(scheduling)
      # else it should behave like a scheduling
      end
      if self.obj.is_a?(String) then self.obj = YAML.load(self.obj) rescue nil ; end
    end

    def key
      key = (obj.respond_to?(:key) ? obj.key : (obj[:key]||obj['key']))
      [ tube, key ].join('-')
    end

    #
    def since_last
      scheduling.last_run - Time.now
    end

    def delay
      scheduling.delay
    end

    # Override this for rescheduling
    def update!
      scheduling.total_runs = scheduling.total_runs.to_i + qjob.stats['releases']
      scheduling.last_run   = Time.now
      p ['updated', self.scheduling]
    end

    def to_hash flatten=true
      hsh = super()
      hsh["scheduling"]   = scheduling.to_hash
      hsh["obj"]          = obj.to_hash
      if flatten
        hsh["scheduling"] = hsh['scheduling'].to_yaml
        hsh["obj"]        = hsh['obj'].to_yaml
      end
      p ['to_hash', hsh, self.scheduling]
      hsh
    end
  end
end

Beanstalk::Job.class_eval do
  def key
    body
  end

  def priority
    pri
  end

  def tube
    stats['tube']
  end
end
