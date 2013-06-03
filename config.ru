# Load gems
require "rubygems"
require "bundler"

env = ENV["RACK_ENV"] || "development"
Bundler.require :app, env.to_sym

Dir.glob("#{File.dirname(__FILE__)}/lib/**/*.rb") { |file| require file }

# Load app
require File.expand_path("app/app.rb", File.dirname(__FILE__))

map "/assets" do
	environment = Sprockets::Environment.new

	# Include handlebars.js
	require "handlebars_assets"
	# `handlebar_assets`' Handlebars version doesn't cooperate with the `assigns`
	# helper
	HandlebarsAssets::Config.compiler = "handlebars.js"
	HandlebarsAssets::Config.compiler_path = File.dirname(__FILE__) + "/vendor/assets/javascripts/"
	environment.append_path HandlebarsAssets.path

	types = %w(images javascripts stylesheets)
	paths = %w(app vendor)
	paths.each do |path|
		types.each do |type|
			environment.append_path "#{path}/assets/#{type}"
		end
	end

	Sprockets::Helpers.configure do |config|
		config.environment = environment
		config.prefix = "/assets"
		config.digest = false
	end

	run environment
end

CarrierWave.configure do |config|
	config.fog_credentials = {
		provider: "AWS",
		aws_access_key_id: ENV["AWS_KEY"] || "",
		aws_secret_access_key: ENV["AWS_SECRET"] || ""
	}

	config.fog_directory = ENV["FOG_DIRECTORY"] || ""
	config.permissions = 0644
end

map "/" do
	run App.new
end
