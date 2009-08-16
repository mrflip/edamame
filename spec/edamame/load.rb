#!/usr/bin/env ruby
$: << File.dirname(__FILE__)+'/../../lib'
require 'rubygems'
require 'json'
require 'edamame'

pq = Edamame::PersistentQueue.new(
  :store => { :type => 'TyrantStore', :uri => ':11212'},
  :queue => { :type => 'BeanstalkQueue', :beanstalkd_uris => ['localhost:11210'] }
  )

pq.store.each do |key, val|
  puts "removing #{key}"
  pq.store.delete key
end
pq.hoard.each do |job|
  puts job.body
end

[
['test', "0", "65536", "120", "1", "10", "0", "20090814012345", {"type"=>"Every", "prev_rate"=>12}, body={"query_term"=>"night"}],
['test', "0", "65536", "120", "1", "10", "0", "20090814012345", {"type"=>"Every", "prev_rate"=> 7}, body={"query_term"=>"day"}],
['test', "0", "65536", "120", "1", "10", "0", "20090814012345", {"type"=>"Every", "prev_rate"=>15}, body={"query_term"=>"hot"}],
# ['test', "0", "65536", "120", "1", "10", "0", "20090814012345", {"type"=>"Every", "prev_rate"=>9}, body={"query_term"=>"cold"}],
# ['test', "0", "65536", "120", "1", "10", "0", "20090814012345", {"type"=>"Every", "prev_rate"=>3}, body={"query_term"=>"hate"}],
# ['test', "0", "65536", "120", "1", "10", "0", "20090814012345", {"type"=>"Every", "prev_rate"=>4}, body={"query_term"=>"love"}],
].each do |args|
  job = Edamame::Job.new *args
  pq.store.set job.key, job
end

pq.load
