require 'edamame/queue'
require 'edamame/key_store'


module Edamame
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
