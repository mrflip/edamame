module Edamame

  module Scheduling
    extend FactoryModule

    # def type
    #   self.class.to_s
    # end
    # def to_hash
    # end

    class Every < Struct.new(:period)
      def delay
        period
      end
    end
    class At < Struct.new(:time)
      def initialize *args
        super *args
        self.time = Time.parse(time) if time.is_a?(String)
      end
      def delay
        time - Time.now
      end
    end
    class Once < Struct.new(:delay)
    end
    class Rescheduling < Struct.new(
        :period,
        :total_items,
        :goal_items,
        :prev_max)
      cattr_accessor :min_resched_delay, :max_resched_delay
      self.min_resched_delay = 10
      self.max_resched_delay = 24*60*60
      def delay
        period
      end
    end
  end

end
