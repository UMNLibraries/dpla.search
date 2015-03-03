# Precompile assets
load 'deploy/assets'
require "rvm/capistrano"

server 'hub.lib.umn.edu', :app, :web, :primary => true

set :rvm_ruby_string, 'ruby-2.1.2@search'

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end