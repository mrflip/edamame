$: << File.dirname(__FILE__)
require 'god_process'
require 'god_email'
require 'beanstalkd_god'
require 'tyrant_god'
require 'sinatra_god'
require 'god_site_config'

# For debugging:
#
#   sudo god -c /Users/flip/ics/edamame/utils/god/edamame.god -D
#
# (for production, use the etc/initc.d script in this directory)


FAITHFUL = [
  [BeanstalkdGod, { :port => 11210 }],
  [TyrantGod,     { :port => 11212, :db_dirname => '/data/distdb', :db_name => 'flat_delay_queue.tct' }],
  [TyrantGod,     { :port => 11219, :db_dirname => '/data/distdb', :db_name => 'foo_queue.tct' }],
  [TyrantGod,     { :port => 11222, :db_dirname => '/data/distdb', :db_name => 'fetched_urls.tch' }],
  #  [SinatraGod,    { :port => 11219, :app_dirname => File.dirname(__FILE__)+'/../../app/edamame_san' }],
]

FAITHFUL.each do |klass, config|
  proc = klass.create(config.merge :flapping_notify => 'default')
  proc.mkdirs!
end
