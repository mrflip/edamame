#
# -host   name        : specify the host name or the address of the server.  By default, every network address is bound.
# -port   num         : specify the port number.  By default, it is 1978.
#
# -thnum  num         : specify the number of worker threads.  By default, it is 8.
# -tout   num         : specify the timeout of each session in seconds.  By default, no timeout is specified.
#
# -log    path        : output log messages into the file.
# -ld                 : log debug messages also.
# -le                 : log error messages only.
# -ulog   path        : specify the update log directory.
# -ulim   num         : specify the limit size of each update log file.
# -uas                : use asynchronous I/O for the update log.
#
# -sid    num         : specify the server ID.
# -mhost  name        : specify the host name of the replication master server.
# -mport  num         : specify the port number of the replication master server.
# -rts    path        : specify the replication time stamp file.
# -rcc                : check consistency of replication.
#
# -skel   name        : specify the name of the skeleton database library.
# -ext    path        : specify the script language extension file.
# -extpc  name period : specify the function name and the calling period of a periodic command.
# -mask   expr        : specify the names of forbidden commands.
# -unmask expr        : specify the names of allowed commands.
#
class TyrantGod < GodProcess
  TyrantGod::DEFAULT_OPTIONS = {
    :listen_on      => '0.0.0.0',
    :port           => 11200,
    :db_dirname     => '/tmp',
    #
    :max_cpu_usage  => 50.percent,
    :max_mem_usage  => 150.megabytes,
    :monitor_group  => 'tyrants',
    :server_exe     => '/usr/local/bin/ttserver',
  }
  def self.default_options() super.deep_merge(TyrantGod::DEFAULT_OPTIONS)           ; end
  def self.site_options()    super.deep_merge(global_site_options[:tyrant_god]||{}) ; end

  def self.kind
    :ttyrant
  end

  def dbname
    basename = options[:db_name] || (handle+'.tct')
    File.join(options[:db_dirname], basename)
  end

  # create any directories required by the process
  def mkdirs!
    super
    FileUtils.mkdir_p File.dirname(dbname)
  end

  def start_command
    [
      options[:server_exe],
      "-host #{options[:listen_on]}",
      "-port #{options[:port]}",
      "-log  #{process_log_file}",
      dbname
    ].flatten.compact.join(" ")
  end
end
