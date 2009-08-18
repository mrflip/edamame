module Edamame
  module Queue
    #
    # Persistent job queue for periodic requests.
    #
    # Jobs are reserved, run, and if successful put back with an updated delay parameter.
    #
    # This is useful for mass scraping of timelines (RSS feeds, twitter search
    # results, etc. See http://github.com/mrflip/wuclan for )
    #
    class BeanstalkQueue < Edamame::Queue::Base
      DEFAULT_OPTIONS = {
        :priority          => 65536,    # default job queue priority
        :time_to_run       => 60*5,     # 5 minutes to complete a job or assume dead
        :uris              => ['localhost:11300'],
        :default_tube      => nil,
      }
      attr_accessor :options

      #
      # beanstalk_pool -- specify nil to use the default single-node ['localhost:11300'] pool
      #
      def initialize _options={}
        self.options = DEFAULT_OPTIONS.merge(_options)
      end

      #
      # Add a new Job to the queue
      #
      def put job
        beanstalk.yput job.to_hash(false), job.priority, job.delay, job.ttr
      end

      #
      # Remove the job from the queue.
      #
      def delete(job)
        job.delete
      end

      #
      # Returns the job to the queue, to be re-run later.
      #
      # release'ing a job acknowledges it was completed, successfully or not
      #
      def release(job)
        job.release job.priority, job.delay
      end

      #
      # Take the next (highest priority, delay met) job.
      # Set timeout (default is 10s)
      # Returns nil on error or timeout. Interrupt error passes through
      #
      def reserve timeout=10
        begin
          job = beanstalk.reserve(timeout) or return
        rescue Beanstalk::TimedOut => e ; warn e.to_s ; sleep 0.4 ; return ;
        rescue StandardError => e       ; warn e.to_s ; sleep 1   ; return ; end
        job
      end

      #
      # Shelves the job.
      #
      def bury
        job.bury job.priority
      end

      # The beanstalk pool which acts as job queue
      def beanstalk
        @beanstalk ||= Beanstalk::Pool.new(options[:uris], options[:default_tube])
      end
      # Close the job queue
      def close
        @beanstalk.close if @beanstalk
        @beanstalk = nil
      end

      # Stats on job count across the pool
      def beanstalk_stats
        beanstalk.stats.select{|k,v| k =~ /jobs/}
      end
      # Total jobs in the queue, whether reserved, ready, buried or delayed.
      def beanstalk_total_jobs
        stats = beanstalk.stats
        [:reserved, :ready, :buried, :delayed].inject(0){|sum,type| sum += stats["current-jobs-#{type}"]}
      end

    end # class
  end
end

