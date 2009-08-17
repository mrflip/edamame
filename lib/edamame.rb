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
    def reschedule job
      release job
    end
    def release job
      store.save    job
      job.qjob.release job.priority, job.delay
    end
    def bury job
      store.bury job
      queue.bury job.id, job.priority
    end
    #
    # Batch operations
    #
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
