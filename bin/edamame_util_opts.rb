
CONFIG = Trollop::options do
  opt :queue,  'host:port for the beanstalkd queue', :type => String, :required => true
  opt :store,  'host:port for the backing store',    :type => String, :required => true
  opt :handle, 'label for this scrape',              :type => String, :required => true
end
CONFIG[:store].gsub!(/^localhost:/, ':') # store must *not* have localhost:
CONFIG[:queue].gsub!(/^:/, 'localhost:') # queue must have localhost:
CONFIG[:tube] = (CONFIG[:handle] || 'default').gsub(/[^A-Z0-9a-z\-]+/,'')

