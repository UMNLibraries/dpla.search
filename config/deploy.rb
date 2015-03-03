set :stages, %w(production staging)
set :default_stage, "staging"
require 'capistrano/ext/multistage'
require 'bundler/capistrano'

set :application, "hub.search"
set :user, "deploy"
set :group, "deployers"

set :scm, :git
set :repository, "git@github.com:UMNLibraries/#{application}.git"
set :deploy_to, "/swadm/var/www/html/#{application}"
set :deploy_via, :remote_cache
set :rails_env, 'production'

set :use_sudo, false

set :normalize_asset_timestamps, false


after 'deploy:update_code', 'deploy:symlink_extra'

namespace :deploy do
  desc "Symlinks the extra files in the shared directory"
  task :symlink_extra, :roles => :app do
    run "ln -nfs #{deploy_to}/shared/config/database.yml #{release_path}/config/database.yml"
  end
end