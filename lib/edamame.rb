require 'wukong/extensions'
require 'monkeyshines/utils/logger'
require 'monkeyshines/utils/factory_module'
require 'beanstalk-client'
require 'edamame/job'
require 'edamame/queue'
require 'edamame/store'
require 'edamame/scheduling'

module Edamame

  class PersistentQueue
    DEFAULT_CONFIG = {
      :queue => { :type => :beanstalk, :pool => ['localhost:11300'] }
    }
    attr_reader :store, :queue
    def initialize options={}
      @store = Edamame::Store.create options[:store]
      @queue = Edamame::Queue.create options[:queue]
    end

    #
    # Add a new Job to the queue
    #
    def put job
      store.save job
      queue.put job
    end

    # Alias for put(job)
    def << job
      put job
    end

    # Retrieve named record
    def get key
      Edamame::Job.from_hash store.get(key)
    end

    #
    # Request a job fom the queue for processing
    #
    def reserve timeout=nil
      job = queue.reserve(timeout)
    end

    #
    # Remove the job from the queue.
    #
    def delete job
      store.delete job
      queue.delete job
    end

    #
    # Returns the job to the queue, to be re-run later.
    #
    # release'ing a job acknowledges it was completed, successfully or not
    #
    def release job
      store.save    job
      queue.release job
    end

    #
    # Shelves the job.
    #
    def bury job
      store.bury job
      queue.bury job
    end

    #
    # Returns each job as it appears in the queue.
    #
    # all jobs -- active, inactive, running, etc -- are returned,
    # and in some arbitrary order.
    #
    def each *args, &block
      store.each *args, &block
    end

    #
    # Loads all jobs from the backing store into the queue.
    #
    def load
      hoard
      unhoard
    end

  protected
    #
    # Destructively strips the beanstalkd queue of all of its jobs.
    #
    # This is the only way (I know) to enumerate all of the jobs in the queue --
    # certainly the only way that respects concurrency.
    #
    # You shouldn't use this in general; the point of the backing store is to
    # allow exactly such queries and enumeration. See #each instead.
    #
    def hoard &block
      jobs = []
      loop do
        kicked = queue.beanstalk.open_connections.map{|conxn| conxn.kick(20) }
        break if (queue.beanstalk_total_jobs == 0) && (!queue.beanstalk.peek_ready)
        qjob = queue.reserve(15) or break
        yield qjob
        qjob.delete
      end
      jobs
    end

    #
    # Loads all jobs from the backing store into the queue.
    #
    # The queue must be emptied of all jobs before running this command:
    # otherwise jobs will be duplicated.
    #
    def unhoard
      store.each do |key, hsh|
        job = Edamame::Job.from_hash hsh
        put job
      end
    end

    #
    #
    #
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
        release job
        log job
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
