require 'yaml'
SITE_CONFIG_FILE = ENV['HOME']+'/.monkeyshines'
SITE_CONFIG = YAML.load(File.open(SITE_CONFIG_FILE))
God.setup_email SITE_CONFIG[:email]
