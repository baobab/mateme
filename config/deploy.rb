set :staging, CLI.ui.ask("Do you want to stage this deployment? (y/n): ") == 'y'
set :repository, "git://github.com/jeffrafter/mateme.git"  
set :domain, "neno:8999"
set :application, staging ? "staging" : "mateme"
set :keep_releases, 3
set :scm, :git
set :deploy_via, :remote_cache
set :deploy_to, "/var/www/#{application}"
set :branch, "master"
set :user, "deploy"
set :runner, "deploy"
set :use_sudo, :false

role :app, "#{domain}"
role :web, "#{domain}"
role :db,  "#{domain}", :primary => true

# == CONFIG ====================================================================
namespace :init do
  namespace :config do
    desc "Create database.yml"
    task :database do
      if Capistrano::CLI.ui.ask("Create database configuration? (y/n): ") == 'y'
        set :db_name, Capistrano::CLI.ui.ask("database: ")
				set :db_user, Capistrano::CLI.ui.ask("database user: ")
				set :db_pass, Capistrano::CLI.password_prompt("database password: ")			
				database_configuration =<<-EOF
---
login: &login
  adapter: mysql
  host: localhost
  database: #{db_name}
  username: #{db_user}
  password: #{db_pass}

production:
  <<: *login

EOF
				run "mkdir -p #{shared_path}/config"
				put database_configuration, "#{shared_path}/config/database.yml"
		  end		
    end
    
    desc "Symlink shared configurations to current"
    task :localize, :roles => [:app] do
      %w[database.yml].each do |f|
        run "ln -nsf #{shared_path}/config/#{f} #{current_path}/config/#{f}"
      end
    end 		
  end  
end

# == OpenMRS ===================================================================
namespace :openmrs do 
  desc "Load the OpenMRS application defaults"
  task :bootstrap_load_defaults, :roles => :app do
    run "cd #{current_path} && rake openmrs:bootstrap:load:defaults RAILS_ENV=production"
  end

  desc "Load the OpenMRS site defaults"
  task :bootstrap_load_site, :roles => :app do
    set :site_arv_code, Capistrano::CLI.ui.ask("Enter the site ARV code: ")
    run "cd #{current_path} && rake openmrs:bootstrap:load:site SITE=#{site_arv_code} RAILS_ENV=production"
  end
end      


# == DATABASE ==================================================================
namespace :db do
  desc "Backup your Database to #{shared_path}/backup"
  task :backup, :roles => :db, :only => {:primary => true} do
    set :db_name, Capistrano::CLI.ui.ask("Database: ")
    set :db_user, Capistrano::CLI.ui.ask("Database user: ")
    set :db_pass, Capistrano::CLI.password_prompt("Database password: ")
    now = Time.now
    run "mkdir -p #{shared_path}/backup"
    backup_time = [now.year,now.month,now.day,now.hour,now.min,now.sec].join('-')
    set :backup_file, "#{shared_path}/backup/#{application}-snapshot-#{backup_time}.sql"
    run "mysqldump --add-drop-table -u #{db_user} -p #{db_pass} #{db_name} --opt | bzip2 -c > #{backup_file}.bz2"
  end
end

# == DEPLOY ======================================================================
namespace :deploy do
  desc "Start application"
  task :start do
    run "touch #{current_path}/tmp/restart.txt"
  end
  
  desc "Restart application"
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end  
end

# == TASKS =====================================================================
before "deploy:migrate", "db:backup"
after "deploy:setup", "init:config:database"
after "deploy:symlink", "init:config:localize"