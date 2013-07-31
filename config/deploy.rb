set :stages, ['local', 'development', 'staging', 'production']
set :default_stage, 'development'

require 'capistrano/ext/multistage'

#app_dir = "/u/apps/appname"
set :application, "appname"
set :repository,  "git@github.com:user/appname"
#set :deploy_to,		app_dir
#set :unicorn_pid, "#{app_dir}/shared/pids/unicorn.pid"
set :ssh_options, { forward_agent: true } # , port: 123
set :deploy_via,	:remote_cache
set :branch, 'develop'
set :user, 'deploy_user'
set :use_sudo, false
# Rids us of a number of annoying errors.
set :normalize_asset_timestamps, false

# Superceded by capistrano multistage.
#role :web, "server"                          # Your HTTP server, Apache/etc
#role :app, "your app-server here"                          # This may be the same as your `Web` server
#role :db,  "your primary db-server here", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

namespace :appname do
	task :create_symlink do
		run "ln -s #{fetch(:deploy_to)}/shared/config.yml #{fetch(:deploy_to)}/current/config/config.yml"
	end
	task :restart_unicorn do
		run "~/.rbenv/shims/ruby ~/unicorn_graceful.rb"
	end
	task :bundle_install do
		run "cd /u/apps/#{fetch(:application)}/current ; ~/.rbenv/shims/gem install bundler ; ~/.rbenv/shims/bundle install ; ~/.rbenv/bin/rbenv rehash"
	end
	task :git_tag do  # Create a nice environment-date-time tag for the release.
		date = nil
		environment = fetch(:stage).to_s
		IO.popen("git log -n 1 --date=iso") do |git_log|
			git_log.each do |line|
				if line =~ /Date:\s+(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})/
					date = $1.gsub /:/, "-"
					date.gsub! /\s+/, "-"
				end
			end
		end
		tag = "#{environment}-#{date}"

		unless date =~ /^(\d{4}\-\d{2}\-\d{2}-\d{2}\-\d{2}\-\d{2})$/
			raise Exception.new("#{date_str} is an invalid date string.")
		end

		unless fetch(:stages).include? environment
			raise Exception.new("#{environment} is not a valid environment")
		end

		system "git tag #{tag}"
		system "git push origin --tags"
	end

end

after "deploy:restart", "deploy:cleanup"
after "deploy:create_symlink", "appname:create_symlink"
after "appname:create_symlink", "appname:bundle_install"
after "appname:restart_unicorn", "appname:git_tag"

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end
