module Edamame
  class PersistentQueue
    DEFAULT_OPTIONS = {
      :queue => { :type => :beanstalk_queue, :uris => ['localhost:11100'] },
      :store => { :type => :tyrant_store,    :uri  =>           ':11101'  }
    }
    # Hash of options used to create this Queue.  Don't mess with this after
    # creating the object -- it will be futile, at best.
    attr_reader :options
    # The default tube for the transient queue
    # Tube name must be purely alphanumeric
    attr_reader :tube
    # The database backing store to use, probably a Edamame::Store
    attr_reader :store
    # The priority queue to use, probably a Edamame::Queue
    attr_reader :queue
    #
    # Create a PersistentQueue with options
    #
    # @param [Hash] options the options to create a message with.
    # @option options [String] :tube  The default tube for the transient queue
    # @option options [String] :queue Option hash for the Edamame::Queue
    # @option options [String] :store Option hash for the Edamame::Store
    #
    def initialize _options={}
      @options = PersistentQueue::DEFAULT_OPTIONS.deep_merge(_options)
      @tube    = options[:tube] || :default
      @store   = Edamame::Store.create options[:store]
      @queue   = Edamame::Queue.create options[:queue].merge(:default_tube => @tube)
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
    # Alias for put(job)
    def << job
      put job
    end

    # Set the default tube
    def tube= _tube
      return if @tube == _tube
      puts "#{self.class} setting tube to #{_tube}, was #{@tube}"
      queue.tube = @tube = _tube
    end

    # Retrieve named record
    def get key, klass=nil
      klass ||= Edamame::Job
      hsh = store.get(key) or return
      klass.from_hash hsh
    end

    #
    # Request a job fom the queue for processing
    #
    def reserve timeout=nil, klass=nil
      qjob     = queue.reserve(timeout) or return
      job      = get(qjob.key, klass)   or return
      job.qjob = qjob
      job
    end

    #
    # Remove the job from the queue.
    #
    def delete job
      store.delete job.key
      queue.delete job.qjob
    end

    #
    # Returns the job to the queue, to be re-run later.
    #
    # release'ing a job acknowledges it was completed, successfully or not
    #
    def release job
      job.update!
      store.save    job
      queue.release job.qjob, job.priority, job.scheduling.delay
    end

    #
    # Returns each job as it appears in the queue.
    #
    # all jobs -- active, inactive, running, etc -- are returned,
    # and in some arbitrary order.
    #
    def each klass=nil, &block
      klass ||= Edamame::Job
      store.each_as(klass) do |key, job|
        yield job
      end
    end

    #
    # Loads all jobs from the backing store into the queue.
    #
    def load &block
      hoard do |job|
        yield(job) if block
        unless store.include?(job.key)
          warn "Missing job: #{job.inspect}"
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
    def unhoard klass=nil, &block
      each(klass) do |job|
        self.tube = job.tube
        yield(job) if block
        queue.put job, job.priority, Edamame::IMMEDIATELY
      end
    end
  end

end
