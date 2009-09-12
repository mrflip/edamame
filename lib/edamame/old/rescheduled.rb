module Edamame
  module Rescheduled


      # ===========================================================================
      #
      # Rescheduling

      #
      # Finish the qjob and re-insert it at the same priority but with the new
      # delay setting.
      #
      def reschedule qjob, scrape_job
        priority = qjob.stats['pri']
        qjob.delete
        self.save scrape_job, priority
      end

      #
      # Flattens the scrape_job and enqueues it with a delay appropriate for the
      # average item rate so far. You can explicitly supply a +priority+ to
      # override the priority set at instantiation.
      #
      # This doesn't delete the job -- use reschedule if you are putting back an
      # existing qjob.
      #
      def save scrape_job, priority=nil, delay=nil
        body       = scrape_job.to_flat.join("\t")
        delay    ||= delay_to_next_scrape(scrape_job)
        priority ||= options[:priority]
        log scrape_job, priority, delay
        job_queue.put body, priority, delay, options[:time_to_run]
      end
      # delegates to #save() -- priority and delay are unchanged.
      def <<(scrape_job) save scrape_job  end

      #
      # if we can't determine an actual rate, uses max_resched_delay (assumes it
      # is rare)
      #
      def delay_to_next_scrape scrape_job
        rate  = scrape_job.avg_rate or return max_resched_delay
        delay = items_goal.to_f / rate
        delay = delay.clamp(min_resched_delay, max_resched_delay)
        delay.to_i
      end

      #
      # A (very prolix) log statement
      #
      def log scrape_job, priority=nil, delay=nil
        delay ||= delay_to_next_scrape(scrape_job)
        rate_str = scrape_job.avg_rate ? "%10.5f/s" % (scrape_job.avg_rate) : " "*12
        ll = "Rescheduling\t#{"%-23s"%scrape_job.query_term}\t"
        ll << "%6d" % priority if priority
        ll << "\t#{rate_str}"
        ll << "\t#{"%7d" % (scrape_job.prev_items||0)}"
        ll << "\t#{"%4d"%(scrape_job.new_items||0)} nu"
        ll << "\tin #{"%8.2f" % delay} s"
        ll << "\t#{(Time.now + delay).strftime("%Y-%m-%d %H:%M:%S")}"
        Log.info ll
      end

      # ===========================================================================
      #
      # Beanstalkd interface
      #

      #
      # De-serialize the scrape job from the queue.
      #
      def scrape_job_from_qjob qjob
        args           = qjob.body.split("\t")
        # request_klass = Wukong.class_from_resource(args.shift)
        scrape_job     = request_klass.new(*args[1..-1])
      end

      # Take the next (highest priority, delay met) job.
      # Set timeout (default is 10s)
      # Returns nil on error or timeout. Interrupt error passes through
      def reserve_job! to=10
        begin  qjob = job_queue.reserve(to)
        rescue Beanstalk::TimedOut => e ; Log.info e.to_s ; sleep 0.4 ; return ;
        rescue StandardError => e       ; Log.warn e.to_s ; sleep 1   ; return ; end
        qjob
      end

  end
end
