#config/deploy.rb
require 'bundler/capistrano'
# capistrano-progressbar
# set task count
set :task_count, 20
require 'capistrano-progressbar'

set :application, "iEat"
set :scm, :git
set :deploy_via, :remote_cache
set :repository,  "git://github.com/Zhengquan/iEat.git" 
set :stages, %w(production staging)
set :default_stage, "staging"
set :use_sudo, false
set :ruby_string, "ruby-1.9.3-p194"

ssh_options[:port] = 1205
# deploy
set  :rails_env,   :production
role :web,        "110.75.189.209"                         # Your HTTP server, Apache/etc
role :app,        "110.75.189.209"                         # This may be the same as your `Web` server
role :db,         "110.75.189.209", :primary => true       # This is where Rails migrations will run
set  :user,       ENV['DEPLOY_USER']
set  :password,   ENV['DEPLOY_PASS']

default_run_options[:pty] = true

task :production do
  set  :branch,      "master"
  puts " Deploying \033[1;41m  production... \033[0m"
end
# staging
task :staging do
  
  deploy_branch = current_branch
  abort("Warning: You can't using sdeploy to deploy master branch!!!")  if deploy_branch == "master"
  abort("Warning: The remote branch is not existed! ") if (not check_remote_branch_exist?(deploy_branch)) && (not ARGV.any?{ |option| option =~ /-T|--tasks|-e|--explain/ })
  set  :branch,   deploy_branch
  puts " Deploying \033[1;42m #{deploy_branch}... \033[0m"
end

def current_branch
  %x[
    ref=$(git symbolic-ref HEAD 2> /dev/null) || return;
    echo ${ref#refs/heads/}
    ].strip
end

def check_remote_branch_exist? branch
  remote_branches = %x[git ls-remote #{fetch(:repository)}].split(/\n/).each{|item| item.gsub!(/.*\trefs\/heads\//,'')}[1..-1]
  # remote_branches = %x[git branch -r].split(/\n\s*/).each{|item| item.gsub!(/\s+|#{remote_name}\//,'')}
  remote_branches.include? branch
end

if stages.include?(ARGV.first)
  # Execute the specified stage so that recipes required in stage can contribute to task list
  find_and_execute_task(ARGV.first) if ARGV.any?{ |option| option =~ /-T|--tasks|-e|--explain/ }
else
  # Execute the default stage so that recipes required in stage can contribute tasks
  find_and_execute_task(default_stage) if exists?(:default_stage)
end

set :bundle_flags,    "--quiet"
set :deploy_to, "/prod/dev/#{application}"
set :application_path, "#{deploy_to}/current"
set :sp_folder, "#{application_path}/app/Stored procedures"
set :public_path, "#{application_path}/public"

#ruby
set :ruby_binary, "/usr/local/rvm/rubies/#{fetch(:ruby_string)}/bin/ruby"
set :bundle_binary, "/usr/local/rvm/gems/#{fetch(:ruby_string)}@global/bin/bundle"
# Unicorn
set :unicorn_binary, "#{fetch('bundle_binary')} exec unicorn_rails"
set :unicorn_config, "#{deploy_to}/current/config/unicorn.rb"
set :unicorn_pid, "#{deploy_to}/current/tmp/pids/unicorn.pid"
set :rake, "#{fetch('bundle_binary')} exec rake"
set :rails, "#{fetch('bundle_binary')} exec rails"


# common
check_alive =  Proc.new {|pid|
  result =  capture <<-EOF.compact
      cd #{application_path} && 
      if [ -f #{pid} ];then 
        if $(kill -0 `cat #{pid}` >/dev/null 2>&1); then 
          echo true;
        else
          echo false;
        fi; 
      else
         echo false;
      fi
      EOF
      ;
  result !~ /false/
}

set :default_environment, {
  'PATH' => "/usr/local/rvm/gems/#{fetch(:ruby_string)}/bin:/usr/local/rvm/gems/#{fetch(:ruby_string)}@global/bin:/usr/local/rvm/rubies/#{fetch(:ruby_string)}/bin:/usr/local/rvm/bin:/mongodb/bin:/redis/bin:/mysql/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games",
  'RUBY_VERSION' => fetch(:ruby_string),
  'GEM_HOME' => "/usr/local/rvm/gems/#{fetch(:ruby_string)}",
  'GEM_PATH' => "/usr/local/rvm/gems/#{fetch(:ruby_string)}:/usr/local/rvm/gems/#{fetch(:ruby_string)}@global"
}

#Bundler
set :bundle_gemfile,  "Gemfile"
set :bundle_dir,      File.join(fetch(:shared_path), 'bundle')
set :bundle_without,  [:development, :test]
set :bundle_cmd,      "bundle" # e.g. "/opt/ruby/bin/bundle"
set :bundle_roles,    {:except => {:no_release => true}}

# God
set :current_restart_task, "none" #using in god

before "bundle:install", "rvm:trust_rvmrc"
before "deploy:restart", "deploy:migrate"

namespace :deploy do
  desc <<-DESC
  Change the default action of deploy:cold including db:create.
    update source code -> create database -> migrate -> precomiple assets -> start unicorn -> start resque
  DESC
  task :cold do
    update
    create
    migrate
    start
  end
  desc "create the database"
  task :create, :roles => :db, :except => { :no_release => true } do
    run "cd #{application_path} && #{rake} db:create RAILS_ENV=#{rails_env}"
  end 
  desc "Refresh the assets and start the unicorn "
  task :start, :roles => :app, :except => { :no_release => true } do 
    run "cd #{application_path} && #{unicorn_binary} -c #{unicorn_config} -E #{rails_env} -D"
  end
  desc "Stop the uniron"
  task :stop, :roles => :app, :except => { :no_release => true } do 
    run "kill `cat #{unicorn_pid}`"
  end
  desc "Stop unicorn with the QUIT signal"
  task :graceful_stop, :roles => :app, :except => { :no_release => true } do
    run "kill -s QUIT `cat #{unicorn_pid}`"
  end
  desc "Reload the unicorn with the signal USR2"
  task :reload, :roles => :app, :except => { :no_release => true } do
    run "kill -s USR2 `cat #{unicorn_pid}`"
  end
  desc "Restart unicorn & Refresh the assets"
  task :restart, :roles => :app, :except => { :no_release => true } do
    # test if the unicorn worker is alive
    if check_alive.call(fetch(:unicorn_pid))
      reload
    else
      start
    end
  end
  desc "Bundle install"
  task :bundle, :roles => :app, :except => { :no_release => true } do
    run "cd #{application_path} && #{fetch('bundle_binary')} install --without development test"
  end
end

namespace :rvm do
  desc  "trust rvm file"
  task :trust_rvmrc, :roles => :app, :except => { :no_release => true } do
    run "rvm rvmrc trust #{release_path}"
  end
end
