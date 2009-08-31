require 'wukong/extensions/hashlike_class'
module Edamame

  module Scheduling
    extend FactoryModule

    # def type
    #   self.class.to_s
    # end
    # def to_hash
    # end

    class Base
      include Wukong::HashlikeClass
      has_members :last_run, :total_runs

      def initialize *args
        members.zip(args).each do |key, val|
          self[key] = val if val
        end
      end

      def last_run_time
        last_run.is_a?(String) ? Time.parse(last_run) : last_run
      end

      def since_last
        Time.now - last_run_time
      end

    end

    class Every < Base
      has_member :delay
    end

    class At < Base
      attr_accessor :time
      def initialize *args
        super *args
        self.time = Time.parse(time) if time.is_a?(String)
      end
      def delay
        @delay ||= time - Time.now
      end
    end

    class Once < Base
      def delay
        nil
      end
    end

    #
    # A recurring task
    #
    # * Run every once in a while -- often enough that you don't miss anything
    #
    #   want to scrape everything between now and prev_item
    #
    # * at the previous run, objects up to prev_time and prev_id
    # * in the current run,  objects up to curr_time and curr_id
    # * average rate
    #
    class Recurring < Base
      has_members :delay, :prev_max, :prev_items, :prev_items_rate
    end


      # :total_items, :goal_items,
      # cattr_accessor :min_resched_delay, :max_resched_delay
      # self.min_resched_delay = 10
      # self.max_resched_delay = 24*60*60

  end

end
