#!/usr/bin/env ruby
$: << File.dirname(__FILE__)+'/../../lib'
require 'rubygems'
require 'json'
require 'edamame'

# pq.hoard.each do |job|
#   puts job.body
# end

broker = Edamame::Broker.new(
  :store => { :type => 'TyrantStore',    :uri => ':11212'},
  :queue => { :type => 'BeanstalkQueue', :uris => ['localhost:11210'] }
  )

# broker.queue.load


broker.work do |job|
  Monkeyshines.logger.info [job, job.scheduling, job.stats, job.obj].inspect
end
