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
      }
      DEFAULT_BEANSTALK_POOL = ['localhost:11300']
      attr_accessor :beanstalk_pool, :items_goal, :min_resched_delay, :max_resched_delay, :config

      #
      # beanstalk_pool -- specify nil to use the default single-node ['localhost:11300'] pool
      #
      def initialize new_config={}
        self.config            = DEFAULT_PARAMS.compact.merge new_config
        self.beanstalk_pool    = config[:beanstalk_pool]
        # self.min_resched_delay = config[:min_resched_delay]
        # self.max_resched_delay = config[:max_resched_delay]
        # self.items_goal        = config[:items_goal]
      end

      #
      # Request Stream
      #
      def each &block
        loop do
          qjob = reserve_job! or next
          scrape_job = scrape_job_from_qjob(qjob)
          # Run the scrape scrape_job
          yield scrape_job
          # reschedule for later
          reschedule qjob, scrape_job
        end
      end

      # The beanstalk pool which acts as job queue
      def job_queue
        @job_queue ||= Beanstalk::Pool.new(beanstalk_pool, config[:beanstalk_tube])
      end

      # Close the job queue
      def finish
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

