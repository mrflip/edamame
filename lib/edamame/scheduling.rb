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
          self[key] = val
        end
      end

      def since_last
      end
    end

    class Every < Base
      has_member :period
      def delay
        period
      end
    end

    class At < Base
      attr_accessor :time
      def initialize *args
        super *args
        self.time = Time.parse(time) if time.is_a?(String)
      end
      def delay
        time - Time.now
      end
    end

    class Once < Base
      attr_accessor :delay
    end

    class Rescheduling < Base
      has_members :period, :total_items, :goal_items, :prev_max

      cattr_accessor :min_resched_delay, :max_resched_delay
      self.min_resched_delay = 10
      self.max_resched_delay = 24*60*60
      def delay
        period
      end
    end
  end

end
