require "bundler/capistrano"
set :application, "gitdeployapp"
 
set :branch, "master"
set :repository,  "https://github.com/railsfans/gitdeployapp.git"
set :scm, "git"
set :user, "railsfans" # 一個伺服器上的帳戶用來放你的應用程式，不需要有sudo權限，但是需要有權限可以讀取Git repository拿到原始碼
set :port, "22"
 
# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "192.168.1.240"                          # Your HTTP server, Apache/etc
role :app, "192.168.1.240"                          # This may be the same as your `Web` server
role :db,  "192.168.1.240", :primary => true # This is where Rails migrations will run

set :deploy_to,        "/opt/#{application}"
set :deploy_via, :remote_cache 


namespace :deploy do
  task :copy_config_files, :roles => [:app] do
    db_config = "#{shared_path}/database.yml"
    run "cp #{db_config} #{release_path}/config/database.yml"
  end
  task :update_symlink do
    run "ln -s #{shared_path}/public/system #{current_path}/public/system"
  end
   task :dev_migrate do
     run "cd /opt/gitdeployapp/current; rake db:migrate"
   end
   task :restart do
     run "/opt/nginx/sbin/nginx -s reload"
   end
   task :start do
     run "/opt/nginx/sbin/nginx"
   end
   task :stop do
     run  "/opt/nginx/sbin/nginx -s stop"
   end
   task :restart, :roles => :app, :except => { :no_release => true } do
     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
   end
 end
