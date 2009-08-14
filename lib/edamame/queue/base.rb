module Edamame
  module Queue
    # extend FactoryModule
    class Base
      DEFAULT_CONFIG = {
        :queue => { :type => :beanstalk, :pool => ['localhost:11300'] }
      }

      def each
      end
      def hoard
      end
      def unhoard
      end

      def job_store
      end

      def queue
        @queue ||= Edamame.create config[:queue]
      end
    end

  end
end
