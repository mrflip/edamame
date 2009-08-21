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
    class BeanstalkQueue
      DEFAULT_OPTIONS = {
        :priority          => 65536,    # default job queue priority
        :time_to_run       => 60*5,     # 5 minutes to complete a job or assume dead
        :uris              => ['localhost:11300'],
        :default_tube      => 'default',
      }
      attr_accessor :options

      #
      # beanstalk_pool -- specify nil to use the default single-node ['localhost:11300'] pool
      #
      def initialize _options={}
        self.options = DEFAULT_OPTIONS.deep_merge(_options.compact)
        options[:default_tube] = options[:default_tube].to_s
      end

      #
      # Add a new Job to the queue
      #
      def put job, priority=nil, delay=nil
        beanstalk.yput(job.to_hash(false),
          (priority || job.priority), (delay || job.delay), job.ttr)
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
      def release job, priority=nil, delay=nil
        job.release( (priority || job.priority), (delay || job.delay) )
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
        return @beanstalk if @beanstalk
        @beanstalk = Beanstalk::Pool.new(options[:uris], options[:default_tube])
        self.tube= options[:default_tube]
        @beanstalk
      end
      # Close the job queue
      def close
        @beanstalk.close if @beanstalk
        @beanstalk = nil
      end

      # uses and watches the given beanstalk tube
      def tube= _tube
        puts "#{self.class} setting tube to #{_tube}, was #{@tube}"
        @beanstalk.use   _tube
        @beanstalk.watch _tube
      end

      # Stats on job count across the pool
      def stats
        beanstalk.stats.select{|k,v| k =~ /jobs/}
      end
      # Total jobs in the queue, whether reserved, ready, buried or delayed.
      def total_jobs
        [:reserved, :ready, :buried, :delayed].inject(0){|sum,type| sum += stats["current-jobs-#{type}"]}
      end

      #
      #
      #
      def empty tube=nil, &block
        tube = tube.to_s if tube
        curr_tube    = beanstalk.list_tube_used.values.first
        curr_watches = beanstalk.list_tubes_watched.values.first
        beanstalk.use   tube if tube
        beanstalk.watch tube if tube
        p ["emptying", tube, beanstalk_total_jobs]
        loop do
          kicked = beanstalk.open_connections.map{|conxn| conxn.kick(20) }
          break if (beanstalk_total_jobs == 0) || (!beanstalk.peek_ready)
          qjob = reserve(5) or break
          yield qjob
          qjob.delete
        end
        beanstalk.use curr_tube
        beanstalk.ignore tube if (! curr_watches.include?(tube))
      end

      def empty_all &block
        tubes = beanstalk.list_tubes.values.flatten.uniq
        tubes.each do |tube|
          empty tube,  &block
        end
      end

    end # class
  end
end

