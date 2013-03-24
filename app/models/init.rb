App.configure do |app|
	app.register Sinatra::ActiveRecordExtension

	# https://github.com/janko-m/sinatra-activerecord
	database_url = ENV["DATABASE_URL"] || ""
	app.set :database, database_url
end
require "carrierwave/orm/activerecord"

models = %w(activity)
models.each { |model| require_relative model }
