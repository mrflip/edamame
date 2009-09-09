$: << File.dirname(__FILE__)
require 'edamame'
require 'edamame/monitoring'
Edamame::SITE_OPTIONS = YAML.load_file(File.dirname(__FILE__)+'/edamame.yaml')

p Edamame::SITE_OPTIONS
#
# For debugging:
#
#   sudo god -c /Users/flip/ics/edamame/utils/god/edamame.god -D
#
# (for production, use the etc/initc.d script in this directory)
#
# TODO: define an EdamameDirector that lets us name these collections.
#

#
# Twitter
#
handle    = 'twitter'
base_port = 11250
# BeanstalkdGod.create :port => base_port + 0, :max_mem_usage => 100.megabytes
# TyrantGod.create     :port => base_port + 1, :db_name => handle+'-queue.tct'
# TyrantGod.create     :port => base_port + 2, :db_name => handle+'-scraped_at.tch'

SinatraGod.create     :port => base_port + 2, :thin_config_yml => '/slice/www/webshines/current/config.yml'
