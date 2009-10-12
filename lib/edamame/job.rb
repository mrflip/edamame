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
      case self.scheduling
      when String
        scheduling_hash = YAML.load(self.scheduling) rescue nil
        self.scheduling = Scheduling.from_hash(scheduling_hash) if scheduling_hash
      when Hash
        self.scheduling = Scheduling.from_hash(scheduling)
      else
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

    #
    # Delegation to scheduling strategy.
    #
    def prev_max()            self.scheduling.prev_max              end
    def prev_max=(val)        self.scheduling.prev_max = val        end
    def prev_items()          self.scheduling.prev_items            end
    def prev_items=(val)      self.scheduling.prev_items = val      end
    def prev_items_rate()     self.scheduling.prev_items_rate       end
    def prev_items_rate=(val) self.scheduling.prev_items_rate = val end
    def delay()               self.scheduling.delay                 end
    def delay=(val)           self.scheduling.delay = val           end
    def last_run()            self.scheduling.last_run              end

    # Override this for rescheduling
    def update!
      scheduling.total_runs = scheduling.total_runs.to_i + qjob.stats['releases']
      scheduling.last_run   = Time.now
    end

    # Fields suitable for emission as a log line.
    def loggable
      "%-15s\t%7d\t%7.2f\t%-23s" % [tube, priority, delay, key]
    end

    def to_hash flatten=true
      hsh = super()
      hsh["scheduling"]   = scheduling.to_hash
      hsh["obj"]          = obj.to_hash
      if flatten
        hsh["scheduling"] = hsh['scheduling'].to_yaml
        hsh["obj"]        = hsh['obj'].to_yaml
      end
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

  # Fields suitable for emission as a log line.
  def loggable
    "%-15s\t%7d\t%7.2f\t%-23s" % [tube, priority, delay, key]
  end
end
