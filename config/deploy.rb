# config valid for current version and patch releases of Capistrano
# config valid only for Capistrano 3.11
# require 'capistrano/ext/multistage'
lock "~> 3.11.0"

set :application, "fca"
set :stages, ["production"]
set :default_stage, "production"
set :repo_url, "https://github.com/wsaqaf/faktaassistenten.git"
set :user, "wsaqaf"
set :deploy_to, "/var/www/faktaassistenten/test"

namespace :deploy do
    desc 'Updating test'
    task :updating_test do
      on roles(:app), in: :groups, limit:1 do
        execute "cd /var/www/faktaassistenten/test"
        execute ". update.sh"
      end
    end

end

after "deploy:updated", "deploy:updating_test"
