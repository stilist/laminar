source "https://rubygems.org"

ruby "1.9.3"

gem "rake"
gem "unicorn"
gem "foreman"

group :development do
	# for Sleep Cycle
	gem "sqlite3"
end

group :app do
	# server
	gem "sinatra", require: "sinatra/base"
	gem "sinatra-static-assets", require: "sinatra/static_assets"
	gem "rack-ssl-enforcer"

	# database
	gem "sinatra-activerecord", require: "sinatra/activerecord"
	gem "pg"
	gem "activerecord-postgres-hstore"

	# remote assets
	gem "carrierwave"
	gem "fog"
	gem "rmagick"

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
	gem "rinku", require: "rinku"

	# pagination
	gem "will_paginate", "~> 3.0.0"

	# console
	gem "tux"

	# services
	gem "fitgem"
	gem "flickraw"
	gem "github_api"
	gem "instagram"
	gem "lastfm"
	gem "pinboard"
	gem "tumblr_client"
	gem "twitter"
	gem "vimeo"
	gem "withings-api"
	gem "youtube_it"

	# helpers
	# https://gist.github.com/pdarche/5034801
	gem "crazylegs"
	gem "redcarpet"
	gem "colormath"
	# http://stackoverflow.com/a/9531191/672403
	gem "certified"
	gem "plist"
end
