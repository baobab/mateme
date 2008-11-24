set :staging, CLI.ui.ask("Do you want to stage this deployment? (y/n): ") == 'y'
set :domain, CLI.ui.ask("Domain you are deploying to (IP Address or Hostname): ")
set :local, "#{`ifconfig | grep "192"`.match(/192\.168\.\d+\.\d+/)}"
set :application, staging ? "staging" : "mateme"
set :keep_releases, 3
set :scm, :git
set :deploy_to, "/var/www/#{application}"
set :user, "deploy"
set :runner, "mongrel"
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

    
    desc "Create cron tasks for success testing, report caching and database backups"
    task :cron do
      if Capistrano::CLI.ui.ask("Create cron jobs? (y/n): ") == 'y'
     		cron_configuration =<<-EOF
# m h  dom mon dow   command
* * * * mon-fri #{current_path}/script/runner -e production 'Success.verify'
EOF
        run "mkdir -p #{shared_path}/backup"
        run "echo 'Current cron configuration'"
        run "crontab -l; echo ---"
        put cron_configuration, "#{shared_path}/scripts/cron"
        # Note this overwrites the cron configuration for the deploy user every time, if you have other crontabs you have to do more work
        run "cat #{shared_path}/scripts/cron | crontab -"
      end  
    end    

    desc "Setup DNS/DHCP server"
    task :dns do
      if Capistrano::CLI.ui.ask("Setup DNS/DHCP server? (y/n): ") == 'y'
        
      end
    end  


    desc "Symlink shared configurations to current"
    task :localize, :roles => [:app] do
      %w[mongrel_cluster.yml database.yml].each do |f|
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


# == NGINX =====================================================================
namespace :nginx do 
  desc "Start Nginx on the app server"
  task :start, :roles => :app do
    sudo "/etc/init.d/nginx start"
  end

  desc "Restart the Nginx processes on the app server by starting and stopping the cluster"
  task :restart , :roles => :app do
    sudo "/etc/init.d/nginx restart"
  end

  desc "Stop the Nginx processes on the app server"
  task :stop , :roles => :app do
    sudo "/etc/init.d/nginx stop"
  end

  desc "Setup the Nginx conf file from the example config"
  task :setup , :roles => :app do
    sudo "cp #{current_path}/config/nginx.conf.example /etc/nginx/nginx.conf"
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
  if Capistrano::CLI.ui.ask("Pull from current machine (#{local})? (y/n): ") == 'y'
    set :distribution, local
    set :repository, "git://#{distribution}/var/www/mateme"
  elsif Capistrano::CLI.ui.ask("Pull from distributed git repository? (y/n): ") == 'y'
    set :distribution, Capistrano::CLI.ui.ask("Repository address: ")
    set :repository, "git://#{distribution}/var/www/mateme"
  elsif Capistrano::CLI.ui.ask("Pull from shared github.com (public)? (y/n): ") == 'y'
    set :repository, "git://github.com/baobab/mateme.git"
  elsif Capistrano::CLI.ui.ask("Pull from alternate github.com (public)? (y/n): ") == 'y'
    set :alternate_repository, CLI.ui.ask("Github Repository (jeffrafter/mateme): ")  
    set :repository, "git://github.com/#{alternate_repository}.git"
  else
  	set :repository, "git://null"
	end	

  desc "Start mongrel cluster"
  task :start do
    run  "cd #{current_path} && sudo mongrel_rails cluster::start"
  end
  
  desc "Stop mongrel cluster"
  task :stop do
    run  "cd #{current_path} && sudo mongrel_rails cluster::stop"
  end
  
  desc "Restart mongrel cluster"
  task :restart do
    run  "cd #{current_path} && sudo mongrel_rails cluster::restart"
  end  
end

# == TASKS =====================================================================
before "deploy:migrate", "db:backup"

after "deploy", "deploy:cleanup"
after "deploy:migrations", "deploy:cleanup"
after "deploy:setup", "init:config:database"
after "deploy:setup", "init:config:mongrel"
after "deploy:setup", "init:config:cron"
after "deploy:symlink", "init:config:localize"

task :after_update_code do
  sudo "chown mongrel:mongrel #{release_path}/public -R" # Caching, in a public app this is not a good idea on closed systems it is okay
  sudo "chown mongrel:mongrel #{release_path}/tmp -R"
  sudo "chown mongrel:mongrel #{release_path}/log -R"
  sudo "chown mongrel:mongrel #{shared_path}/pids -R"
  sudo "chown mongrel:mongrel #{shared_path}/config -R"
end
