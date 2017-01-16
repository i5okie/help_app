lock '3.4.1'

set :application, 'ibc_help_app'
set :deploy_user, 'deploy'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/home/deploy/ibc_help_app'

# Set rbenv type and version
set :rbenv_type, :user # or :system, depends on your rbenv setup
set :rbenv_ruby, '2.2.1'
# set :chruby_ruby, '2.2.1'


# Default value for :scm is :git
set :scm, :git
set :repo_url, 'git@github.com:i5okie/ibc_help_app.git'

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}
set :linked_files, %w{config/application.yml}

# Default value for linked_dirs is []
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }
set :default_env, { path: "/home/deploy/.rubies/ruby-2.2.1/bin/ruby:$PATH"}
# set :passenger_environment_variables, { :path => '/usr/bin/' }
# set :passenger_restart_command, 'passenger-config restart-app'

set :default_stage, 'production'
set :deploy_via, :remote_cache
# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do
  desc 'Restart application'
  after :restart, :restart_passenger do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      within release_path do
        execute :touch, 'tmp/restart.txt'
      end
    end
  end
  # task :restart do
  #   on roles(:app), in: :sequence, wait: 5 do
  #     # Your restart mechanism here, for example:
  #     execute :touch, release_path.join('tmp/restart.txt')
  #   end
  # end

  desc "set environmental variabls"
  task :setenv do
    on roles(:app) do
      execute "export OFFICE_USERNAME=ipolchenko@ibcworld.net OFFICE_PASSWORD=H4kjmjqEh ADMIN_NAME=Ivan P ADMIN_EMAIL=ivan@ibcworld.net ADMIN_PASSWORD=h4kjmjqeh  AWS_ACCESS_KEY=AKIAJNP42UONHBAM2FWQ AWS_SECRET_KEY=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 AWS_ACCOUNT_ID=929615564749 AWS_BUCKET=ibc-assets  WT_PASSWORD=H4kjmjqEh  DO_CLIENTKEY=537faa1d0cfc0bbc194c21cadedc42f9 DO_APIKEY=436b3bad8500e47733e90c93b53d4c63 DO_KEY_NAME=IBC_DO MAILER_SENDER=no-reply@ibcworld.net DOMAIN=help.ibcworld.net"
    end
  end



  before :publishing, 'deploy:setenv'
  after :publishing, :'passenger:restart'
  # after :finishing, 'deploy:restart_passenger'
  after :finishing, 'deploy:cleanup'

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end


  namespace :figaro do
    desc "SCP transfer figaro configuration to the shared folder"
    task :setup do
      transfer :up, "config/application.yml", "#{shared_path}/application.yml", :via => :scp
    end

    desc "Symlink application.yml to the release path"
    task :finalize do
      run "ln -sf #{shared_path}/application.yml #{release_path}/config/application.yml"
    end
  end

end

namespace :logs do
  desc "tail rails logs"
  task :tail_rails do
    on roles(:app) do
      execute "tail -f #{shared_path}/log/#{fetch(:rails_env)}.log"
    end
  end
end
