require 'edamame/queue'
require 'edamame/key_store'


module Edamame
  extend FactoryModule
  class Queue

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

  class JobStore < Edamame::KeyStore
  end

  #
  #
  # id, name, body, timeouts, time-left, age, state, delay, pri, ttr
  #
  class Job < Beanstalk::Job
    def delete
    end
    def put_back
    end
    def release
    end
    def bury
    end
    def touch
    end
  end



end
