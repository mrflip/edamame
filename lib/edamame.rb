require 'wukong/extensions'
require 'monkeyshines/utils/logger'
require 'monkeyshines/utils/factory_module'
require 'beanstalk-client'
require 'edamame/scheduling'
require 'edamame/job'
require 'edamame/queue'
require 'edamame/store'

module Edamame

  class PersistentQueue
    DEFAULT_CONFIG = {
      :queue => { :type => :beanstalk, :pool => ['localhost:11300'] }
    }
    attr_reader :tube, :store, :queue
    def initialize options={}
      @tube  = options[:tube] || :default
      @store = Edamame::Store.create options[:store]
      @queue = Edamame::Queue.create options[:queue].merge(:default_tube => @tube)
    end

    #
    # Add a new Job to the queue
    #
    def put job, *args
      job.tube  = self.tube if job.tube.blank?
      self.tube = job.tube
      return if store.include?(job.key)
      store.save job
      queue.put  job, *args
    end

    def tube= _tube
      return if @tube == _tube
      puts "#{self.class} setting tube to #{_tube}, was #{@tube}"
      queue.tube = @tube = _tube
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
      store.delete job.key
      queue.delete job
    end

    #
    # Returns the job to the queue, to be re-run later.
    #
    # release'ing a job acknowledges it was completed, successfully or not
    #
    def release job
      job.update!
      store.save    job
      queue.release job, job.priority, job.scheduling.delay
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
      store.each do |key, job_hsh|
        yield Edamame::Job.from_hash(job_hsh)
      end
    end

    #
    # Loads all jobs from the backing store into the queue.
    #
    def load &block
      hoard do |job|
        yield(job) if block
        unless store.include?(job.key)
          store.save job
        end
      end
      unhoard &block
    end

    # Returns a hash of stats about the store and queue
    def stats
      { :store_stats => store.stats,
        :queue_stats => queue.stats,
        :tube        => self.tube }
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
      queue.empty tube, &block
    end

    #
    # Loads all jobs from the backing store into the queue.
    #
    # The queue must be emptied of all jobs before running this command:
    # otherwise jobs will be duplicated.
    #
    def unhoard &block
      store.each do |key, hsh|
        job = Edamame::Job.from_hash hsh
        self.tube = job.tube
        yield(job) if block
        queue.put job
      end
    end

    #
    #
    #
    def log line
      Monkeyshines.logger.info line
    end
  end

  class Broker < PersistentQueue
    def reschedule job
      delay = job.scheduling.delay
      if delay
        # log_job job, 'rescheduled', delay, (Time.now + delay).to_flat, job.scheduling.to_flat.join
        release job
      else
        # log_job job, 'deleted'
        delete job
      end
    end
    def log_job job, *stuff
      log [job.tube, job.priority, job.delay, job.obj['key'], *stuff].flatten.join("\t")
    end
    def work timeout=10, &block
      loop do
        job    = reserve(timeout) or break
        result = block.call(job)
        job.update!
        reschedule job
      end
    end
  end
end
