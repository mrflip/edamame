require 'yaml'
SITE_OPTIONS_FILE = ENV['HOME']+'/.monkeyshines'
SITE_OPTIONS = YAML.load(File.open(SITE_OPTIONS_FILE))
God.setup_email SITE_OPTIONS[:email]
