require 'beanstalk-client'
require 'wukong/extensions'
require 'monkeyshines/utils/factory_module'
require 'monkeyshines/utils/logger'
require 'edamame/scheduling'
require 'edamame/job'
require 'edamame/queue'
require 'edamame/store'

# Edamame combines the Beanstalk priority queue with a Tokyo Tyrant database to
# produce a persistent distributed priority job queue system.
#
# * fast, scalable, lightweight and distributed
# * persistent and recoverable
# * scalable up to your memory limits
# * queryable and enumerable jobs
# * named jobs
# * reasonably-good availability.
#
# Like beanstalk, it is a job queue, not just a message queue:
# * priority job scheduling, not just FIFO
# * Supports multiple queues ('tubes')
# * reliable scheduling: jobs that time out are re-assigned
#
# You should start by looking at [Edamame::PersistentQueue]
module Edamame
  autoload :PersistentQueue, 'edamame/persistent_queue'
  autoload :Broker,          'edamame/broker'
end
