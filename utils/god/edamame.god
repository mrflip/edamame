$: << File.dirname(__FILE__)
require 'god_process'
require 'god_email'
require 'beanstalkd_god'
require 'tyrant_god'
require 'god_site_config'

FAITHFUL = [
  [BeanstalkdGod, { :port => 11300 }],
  [BeanstalkdGod, { :port => 11301 }],
  
  [TyrantGod,     { :port => 11200, :db_dirname => '/data/distdb', :db_name => 'foo_queue.tct' }],
]

FAITHFUL.each do |klass, config|
  proc = klass.create(config.merge :flapping_notify => 'default')
  proc.mkdirs!
end
