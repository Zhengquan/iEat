module Rails
  class <<self
    def root
      File.expand_path(__FILE__).split('/')[0..-3].join('/')
    end
  end
end
rails_env = ENV["RAILS_ENV"] || "production"

app = "iEat"
worker_processes 1
preload_app false
timeout 6
listen 3002
app_path = "/prod/dev/#{app}/current"
listen "/tmp/unicorn.#{app}.sock", :backlog => 64
pid "#{app_path}/tmp/pids/unicorn.pid"
stderr_path "#{app_path}/log/unicorn.log"
stdout_path "#{app_path}/log/unicorn.log"

#You may need to set or reset the BUNDLE_GEMFILE environment variable in the before_exec hook
before_exec do |server|
  ENV["BUNDLE_GEMFILE"] = "#{app_path}/Gemfile"
end

before_fork do |server, worker|
  # the database connection
  #  defined?(ActiveRecord::Base) and
  #    ActiveRecord::Base.connection.disconnect!
  old_pid = "#{app_path}/tmp/pids/unicorn.pid.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      puts "Send 'QUIT' signal to unicorn error!"
    end
  end
end
