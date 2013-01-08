# Load gems
require "rubygems"
require "bundler"
Bundler.require :app

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

map "/" do
	run App
end
