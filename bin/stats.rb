#!/usr/bin/env ruby
$: << File.dirname(__FILE__)+'/../../lib'
require 'rubygems'
require 'edamame'
require 'monkeyshines/monitor'

pq = Edamame::PersistentQueue.new(
  :tube  => ARGV[0],
  :queue => { :type => 'BeanstalkQueue', :uris => ['localhost:11210'] },
  :store => { :type => 'TyrantStore',    :uri =>            ':11212'  }
  )

p pq.stats
