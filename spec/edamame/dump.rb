#!/usr/bin/env ruby
$: << File.dirname(__FILE__)+'/../../lib'
require 'rubygems'
require 'edamame'

pq = Edamame::PersistentQueue.new(
  :tube  => ARGV[0] ,
  :store => { :type => 'TyrantStore',    :uri => ':11212'},
  :queue => { :type => 'BeanstalkQueue', :uris => ['localhost:11210'] }
  )

pq.store.each do |key, job|
  p [key, job]
  pq.store.delete key
end

pq.queue.empty_all do |job|
  p [job, job.obj]
end

# pq.load do |job|
#   p job
#   puts ["%-22s" % job.key, job.tube, job.priority, job.delay, job.ttr, job.obj.inspect, job.scheduling.inspect].join("\t")
# end
