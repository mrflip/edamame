#!/usr/bin/env ruby
$: << File.dirname(__FILE__)+'/../../lib'
require 'rubygems'
require 'json'
require 'edamame'

broker = Edamame::Broker.new(
  :queue => { :type => 'BeanstalkQueue', :uris => ['localhost:11210'] },
  :store => { :type => 'TyrantStore',    :uri  =>           ':11212'  }
  )

broker.work do |job|
  Monkeyshines.logger.info [job, job.scheduling, job.stats, job.obj].inspect
end
