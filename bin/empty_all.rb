#!/usr/bin/env ruby
$: << File.dirname(__FILE__)+'/../../lib'
require 'rubygems'
require 'edamame'
require 'monkeyshines/monitor'

pq = Edamame::PersistentQueue.new(
  :queue => { :type => 'BeanstalkQueue', :uris => ['localhost:11210'] },
  :store => { :type => 'TyrantStore',    :uri =>            ':11212'  }
  )

periodic_log = Monkeyshines::Monitor::PeriodicLogger.new(:iters => 1000, :time => 30)
pq.queue.empty_all do |job|
  periodic_log.periodically{ [ job.tube, job.priority, job.delay, job.scheduling, job.obj['key'] ] }
end
