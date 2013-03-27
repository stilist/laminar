Dir.glob("#{File.dirname(__FILE__)}/lib/tasks/*.rake") { |file| import file }

# https://github.com/janko-m/sinatra-activerecord
require "sinatra/activerecord/rake"

desc "Run the server"
task :server do
	system "thin start -p 5050"
end

# Need to do this so ActiveRecord knows about app's database when migrating.
namespace :db do
	# Load gems
	require "rubygems"
	require "bundler"
	Bundler.require :app

	# Load app
	require_relative "app/app.rb"
end
