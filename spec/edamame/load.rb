#!/usr/bin/env ruby
$: << File.dirname(__FILE__)+'/../../lib'
require 'rubygems'
require 'json'
require 'edamame'

pq = Edamame::PersistentQueue.new(
  :store => { :type => 'TyrantStore',    :uri => ':11212'},
  :queue => { :type => 'BeanstalkQueue', :uris => ['localhost:11210'] }
  )

pq.store.each do |key, val|
  puts "db: removing #{key}"
  # job = Edamame::Job.from_hash val
  # p [job.obj, job.scheduling, job.priority, job.delay, job.ttr]
  pq.store.delete key
end
pq.send(:hoard) do |job|
  puts "q: removing #{job.key}"
  p [job.obj, job.scheduling, job.priority, job.delay, job.ttr]
end

include Edamame::Scheduling
[
[:default, 65536, 120, 1, Every.new(3,  "20090814012345"), {:key=>"night"}],
[:default, 65536, 120, 1, Every.new(7,  "20090814012345"), {:key=>"day"  }],
[:default, 65536, 120, 1, Every.new(15, "20090814012345"), {:key=>"hot"  }],
].each do |args|
  job = Edamame::Job.new *args
  pq.store.set job.key, job
  p [job]
  p pq.get job.key
end

[
{ 'scheduling' => Every.new(4), 'obj' => {:key=>"four"}},
{ 'scheduling' => Every.new(5), 'obj' => {:key=>"five"  }},
{ 'scheduling' => Every.new(6), 'obj' => {:key=>"six"  }},
].each do |hsh|
  job = Edamame::Job.from_hash hsh
  job.tube = pq.tube
  pq.store.set job.key, job
  p job
  p pq.get job.key
end


pq.load
