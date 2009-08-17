require 'beanstalk-client'

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
      DEFAULT_PARAMS = {
        :min_resched_delay => 60*5,     # 5 minutes
        :max_resched_delay => 60*60*24, # one day
        :priority          => 65536,    # default job queue priority
        :time_to_run       => 60*5,     # 5 minutes to complete a job or assume dead
        :beanstalkd_uris   => ['localhost:11300']
      }

      attr_accessor :beanstalkd_uris, :items_goal, :min_resched_delay, :max_resched_delay, :config

      #
      # beanstalk_pool -- specify nil to use the default single-node ['localhost:11300'] pool
      #
      def initialize new_config={}
        self.config            = DEFAULT_PARAMS.compact.merge new_config
        self.beanstalkd_uris   = config[:beanstalkd_uris]
        # self.min_resched_delay = config[:min_resched_delay]
        # self.max_resched_delay = config[:max_resched_delay]
        # self.items_goal        = config[:items_goal]
      end



      def put(*args)   job_queue.put     *args  ; end
      def delete(job)  job_queue.delete  job.id ; end
      def release(job) job_queue.release job.id, job.priority, job.delay ; end
      # Take the next (highest priority, delay met) job.
      # Set timeout (default is 10s)
      # Returns nil on error or timeout. Interrupt error passes through
      def reserve timeout=10
        begin  qjob = job_queue.reserve(timeout)
        rescue Beanstalk::TimedOut => e ; warn e.to_s ; sleep 0.4 ; return ;
        rescue StandardError => e       ; warn e.to_s ; sleep 1   ; return ; end
        qjob
      end

      # The beanstalk pool which acts as job queue
      def job_queue
        @job_queue ||= Beanstalk::Pool.new(beanstalkd_uris, config[:beanstalk_tube])
      end
      # Close the job queue
      def close
        @job_queue.close if @job_queue
        @job_queue = nil
      end

      # Stats on job count across the pool
      def job_queue_stats
        job_queue.stats.select{|k,v| k =~ /jobs/}
      end
      # Total jobs in the queue, whether reserved, ready, buried or delayed.
      def job_queue_total_jobs
        stats = job_queue.stats
        [:reserved, :ready, :buried, :delayed].inject(0){|sum,type| sum += stats["current-jobs-#{type}"]}
      end

    end # class
  end
end

