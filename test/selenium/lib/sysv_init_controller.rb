%w(jenkins_controller log_watcher).each { |f| require File.dirname(__FILE__)+"/"+f }

# Runs Jenkins controlled by SysV init script, running on another machine
#
# @attr [String] ssh
#     ssh command line with parameters that control how to access the remote host, such as "ssh -p 2222 localhost"
# @attr [String] host
#     "hostname[:port]" that specifies where it is running
# @attr [String] service
#     SysV service name of Jenkins. By default "jenkins"
# @attr [String] logfile
#     Path to the log file on the target system, default to "/var/log/jenkins/jenkins.log"
class RemoteSysvInitController < JenkinsController
  register :remote_sysv

  JENKINS_DEBUG_LOG = Dir.pwd + "/last_test.log"

  attr_reader :url

  def initialize(args)
    @ssh = args[:ssh]
    @host = args[:host]
    @service = args[:service] || "jenkins"
    @logfile = [args:logfile] || "/var/log/jenkins/jenkins.log"

    @url = "http://#{@host}/"
    @tempdir = "/tmp/jenkins/"+(rand(500000)+100000)
    ssh_exec "mkdir -p #{@tempdir}"

    FileUtils.rm JENKINS_DEBUG_LOG if File.exists? JENKINS_DEBUG_LOG
    @log = File.open(JENKINS_DEBUG_LOG, "w")
  end

  # run the command via ssh
  def ssh_exec(cmd)
    if !system("#{@ssh} #{cmd}")
      raise "Command execution '#{@ssh} #{cmd}' failed"
    end
  end

  def ssh_popen(cmd)
    IO.popen("#{@ssh} #{cmd}")
  end

  def start
    # TODO: set JENKINS_HOME to @tempdir
    ssh_exec "sudo /etc/init.d/#{@service} start"

    @pipe = ssh_popen("sudo tail -f #{@logfile}")

    @log_watcher = LogWatcher.new(@pipe,@log)
    @log_watcher.wait_for_ready
  end

  def stop
    begin
      ssh_exec "sudo /etc/init.d/#{@service} stop"

      @log_watcher.wait_for_ready false
    rescue => e
      puts "Failed to cleanly shutdown Jenkins #{e}"
      puts "  "+e.backtrace.join("\n  ")
    end
  end

  def teardown
    unless @log.nil?
      @log.close
    end
    ssh_exec "sudo rm -rf #{@tempdir}"
  end

  def url
    @base_url
  end

  def diagnose
    puts "It looks like the test failed/errored, so here's the console from Jenkins:"
    puts "--------------------------------------------------------------------------"
    File.open(JENKINS_DEBUG_LOG, 'r') do |fd|
      fd.each_line do |line|
        puts line
      end
    end
  end
end