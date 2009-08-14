$: << File.dirname(__FILE__)
require 'god_process'
require 'god_email'
require 'beanstalkd_god'
require 'tyrant_god'
require 'god_site_config'

require 'yaml'

SITE_CONFIG_FILE = ENV['HOME']+'/.monkeyshines'
SITE_CONFIG = YAML.load(File.open(SITE_CONFIG_FILE))
God.setup_email SITE_CONFIG[:email]

FAITHFUL = [
  [BeanstalkdGod, { :port => 11300 }],
  [BeanstalkdGod, { :port => 11301 }],
  
  [TyrantGod,     { :port => 11200 }],
]

FAITHFUL.each do |klass, config|
  proc = klass.create(config.merge :flapping_notify => 'default')
  proc.mkdirs!
end
