$: << File.dirname(__FILE__)+'/../../lib'
$: << File.dirname(__FILE__)+'/../../../wukong/lib'
$: << File.dirname(__FILE__)+'/../../../monkeyshines/lib'
require 'edamame'
require 'edamame/monitoring'

#
# For debugging:
#
#   sudo god -c /Users/flip/ics/edamame/utils/god/edamame.god -D
#
# (for production, use the etc/initc.d script in this directory)
#
# TODO: define an EdamameDirector that lets us name these collections.
#

GodProcess::GLOBAL_SITE_OPTIONS_FILES << ENV['HOME']+'/.edamame'

# #
# # Twitter
# #
# handle    = 'twitter'
# God.process_group 11250, [
#   # [ BeanstalkdGod, { :max_mem_usage => 100.megabytes } ],
#   # [ TyrantGod,     { :db_name => handle+'-queue.tct' } ],
#   # [ TyrantGod,     { :db_name => handle+'-scraped_at.tch' } ],
#   [ SinatraGod,    { :thin_config_yml => '/slice/www/webshines/current/config.yml' } ],
#   ]

GodProcess.global_site_options[:process_groups].each do |handle, group_info|
  group_info.each do |group, group_options|
    klass = FactoryModule.get_class Kernel, group_options[:type]
    klass.create(group_options)
  end
end

