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
# Lastfm
#
handle    = 'lastfm'
base_port = 11210
BeanstalkdGod.create :port => base_port + 0, :max_mem_usage => 2.gigabytes
TyrantGod.create     :port => base_port + 1, :db_name => handle+'-queue.tct'
TyrantGod.create     :port => base_port + 2, :db_name => handle+'-scraped_at.tch'



#
# Facebook
#
handle    = 'facebook'
base_port = 11250
BeanstalkdGod.create :port => base_port + 0, :max_mem_usage => 100.megabytes
TyrantGod.create     :port => base_port + 1, :db_name => handle+'-queue.tct'
TyrantGod.create     :port => base_port + 2, :db_name => handle+'-scraped_at.tch'
TyrantGod.create     :port => base_port + 3, :db_name => handle+'-registration.tch'
