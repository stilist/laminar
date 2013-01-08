source :rubygems

ruby "1.9.3"

gem "rake"
gem "thin"

group :app do
	# server
	gem "sinatra", require: "sinatra/base"
	gem "sinatra-synchrony", require: "sinatra/synchrony"
	gem "sinatra-static-assets", require: "sinatra/static_assets"

	# database
	gem "sinatra-activerecord", require: "sinatra/activerecord"
	gem "pg"

	# assets
	gem "sprockets"
	gem "coffee-script"
	gem "sprockets-helpers", "~> 0.2"
	gem "sprockets-sass", "~> 0.5"
	gem "sass"
	# Handlebars + HAML, as templates
	gem "handlebars_assets"

	# content
	gem "haml"
	gem "json"
	gem "sinatra-respond_to", require: "sinatra/respond_to"
	# server-side rendering
	gem "handlebars", require: "handlebars"

	# console
	gem "tux"
end
