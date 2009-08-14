require 'edamame/queue'
require 'edamame/store'
require 'wukong/extensions'

module Edamame

  class Broker
    def work &block
      loop do
        job    = pqueue.reserve
        result = block.call(job)
        job.update!
        log job
        reschedule job
      end
    end

    def log job
    end

    def reschedule job
      release job
    end

  end


  class PersistentQueue
    def initialize options={}
      self.store = Edamame::Store.create options[:store]
      self.queue = Edamame::Queue.create options[:pool]
    end

    def put job
      store.put job.key, job
      queue.put job.to_hash, job.priority, job.delay, job.ttr
    end
    def << job
      put job
    end
    def reserve timeout=nil
      hsh = queue.reserve timeout or return
      Job.from_hash hsh
    end
    def delete job
      store.delete job
      queue.delete job.id
    end
    def release job
      store.put job.key, job
      queue.release job.id, job.priority, job.delay
    end
    def bury job
      store.bury job
      queue.bury job.id, job.priority
    end

    def each *args, &block
      store.each *args, &block
    end

  end


  #
  #
  # id, name, body, timeouts, time-left, age, state, delay, pri, ttr
  #
  class Job < Struct.new(
      :priority,
      :tube,
      :ttr,
      :scheduling,
      :prev_run_at,
      :active,
      :runs,
      :failures,
      :body
      ) # < Beanstalk::Job

    def update!
    end

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
    class Every < Struct.new(:period)
    end

    class At < Struct.new(:time)
    end

    class Once
    end

    class Rescheduling < Struct.new(
        :period,
        :prev_items,
        :goal_items,
        :total_items
        )
    end

  end

end

module Wuclan
  module Domains
    module Twitter
      module Scrape
        class TwitterSearchJob < Struct.new(
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
end
