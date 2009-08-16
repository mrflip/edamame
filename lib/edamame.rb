require 'wukong/extensions'
require 'monkeyshines/utils/logger'
require 'monkeyshines/utils/factory_module'
require 'edamame/queue'
require 'edamame/store'

module Edamame

  class PersistentQueue
    DEFAULT_CONFIG = {
      :queue => { :type => :beanstalk, :pool => ['localhost:11300'] }
    }
    attr_reader :store, :queue
    def initialize options={}
      @store = Edamame::Store.create options[:store]
      @queue = Edamame::Queue.create options[:queue]
      p [@store, @queue]
    end
    def reschedule job
      release job
    end
    def put job
      store.save job
      queue.put job.to_hash, job.priority, job.delay, job.ttr
    end
    def << job
      put job
    end
    def reserve timeout=nil
      qjob = queue.reserve(timeout) or return
      job  = Job.from_hash JSON.load(qjob.body)
      job.qjob = qjob
      job
    end
    def delete job
      store.delete job
      queue.delete job.id
    end
    def release job
      store.save    job
      job.qjob.release job.priority, job.delay
    end
    def bury job
      store.bury job
      queue.bury job.id, job.priority
    end
    def each *args, &block
      store.each *args, &block
    end
    def load
      store.each_as(Edamame::Job) do |key, job|
        p job
        queue.put job.to_hash.to_json, job.priority, job.delay, job.ttr
      end
    end
    def hoard
      jobs = []
      loop do
        kicked = queue.job_queue.open_connections.map{|conxn| conxn.kick(20) }
        break if (queue.job_queue_total_jobs == 0) && (!queue.job_queue.peek_ready)
        qjob = queue.reserve(15) or break
        jobs << qjob
        qjob.delete
      end
      jobs
    end
    def log job
      Monkeyshines.logger.info job.inspect
    end
  end

  class Broker < PersistentQueue
    def work &block
      loop do
        job    = reserve(3) or next
        result = block.call(job)
        # job.update!
        log job
        reschedule job
      end
    end
  end

  #
  #
  # id, name, body, timeouts, time-left, age, state, delay, pri, ttr
  #
  Job = Struct.new(
    :tube, :id, :priority, :ttr,
    :active, :runs, :failures, :prev_run_at,
    :scheduling, # :prev_rate, :prev_items, :prev_span_min, :prev_span_max,
    :body
    )
  Job.class_eval do
    attr_accessor :qjob
    def initialize *args
      super *args
      if self.body.is_a?(String) then self.body = JSON.load(self.body) rescue nil ; end
      if self.scheduling.is_a?(String) then self.scheduling = JSON.load(self.scheduling) rescue nil ; end
    end
    def to_hash
      hsh = super.to_hash
      hsh['body'] = self.body.to_json
      hsh['scheduling'] = self.scheduling.to_json
      hsh
    end
    def to_flat
      flat = to_a
      flat[-2] = scheduling.to_json
      flat[-1] = body.to_json
      flat
    end
    def key
      [self.class.to_s, tube, query_term].join("-")
    end
    def query_term
      body['query_term']
    end
    def delay
      scheduling['prev_rate']
    end
    def to_s
      [priority, tube, ttr, scheduling, prev_run_at, active, runs, failures, body].inspect
    end
    def update!
    end

    # def initialize priority, tube, ttr, scheduling, prev_run_at, active, runs, failures, body
    #   self.priority    = priority
    #   self.tube        = tube
    #   self.ttr         = ttr
    #   self.scheduling  = scheduling
    #   self.prev_run_at = prev_run_at
    #   self.active      = active
    #   self.runs        = runs
    #   self.failures    = failures
    #   self.body        = body
    # end

    # {"prev_span_min"=>"2667196308", "priority"=>"100", "prev_rate"=>"0.0109902931357164", "query_term"=>"metallica", "prev_span_max"=>"3277045439", "prev_items"=>"28230"}
    # attr_accessor :
    # def delete
    # end
    # def put_back
    # end
    # def release
    # end
    # def bury
    # end
    # def touch
    # end
  end

  module Scheduling
    Every = Struct.new(:period)
    At    = Struct.new(:time)
    Once  = Struct.new(:dummy)
    Rescheduling = Struct.new( :period, :prev_items, :goal_items, :total_items )
  end

end

module Wuclan
  module Domains
    module Twitter
      module Scrape
        TwitterSearchJob = Struct.new(
          :query_term,
          :priority,
          :prev_items,
          :prev_rate,
          :prev_span_min,
          :prev_span_max
          )
      end
    end
  end
end
