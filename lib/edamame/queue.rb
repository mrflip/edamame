module Edamame
  module Queue
    extend FactoryModule
    autoload :Base,           'edamame/queue/base'
    autoload :BeanstalkQueue, 'edamame/queue/beanstalk'
  end
end
