module Edamame
  module Queue
    extend FactoryModule
    autoload :BeanstalkQueue, 'edamame/queue/beanstalk'
  end
end
