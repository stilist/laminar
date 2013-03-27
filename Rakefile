Dir.glob("#{File.dirname(__FILE__)}/lib/**/*.rb") { |file| require file }
import "#{File.dirname(__FILE__)}/lib/tasks/scheduler.rake"

# scheduler debug
puts "***************** IN RAKEFILE"

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

namespace :twitter do
	client = Twitter::Client.new({
		consumer_key: ENV["TWITTER_APP_KEY"],
		consumer_secret: ENV["TWITTER_APP_SECRET"],
		oauth_token: ENV["TWITTER_USER_KEY"],
		oauth_token_secret: ENV["TWITTER_USER_SECRET"]
	})

	# https://github.com/sferik/twitter/issues/370#issuecomment-15495843
	# (also: https://dev.twitter.com/discussions/15989)
	client.send(:connection).headers["Connection"] = ""

	# TODO pagination
	task :tweets do
		opts = {
			count: 200, # max: 200
			include_rts: true
		}

		# `.reorder` because `Activity` has a `default_scope` for `order`
		newest = Activity.where(activity_type: "post").where(source: "twitter").
				reorder("id DESC").first
		opts.merge!({ since_id: newest["data"]["id"] }) if newest

		posts = client.user_timeline(ENV["TWITTER_USER"], opts)
		total = posts.length

		puts
		puts "*** #{total} new tweets"

		# http://stackoverflow.com/a/8380073/672403
		s2s = lambda { |h| Hash === h ? Hash[h.map { |k, v| [k.to_s, s2s[v]] }] : h }

		ActiveRecord::Base.record_timestamps = false
		posts.each_with_index do |post, idx|
			puts "  * #{post.id} [#{idx + 1}/#{total}]"
			Activity.create({
				source: "twitter",
				activity_type: "post",
				url: "https://twitter.com/#{post["user"]["screen_name"]}/status/#{post.id}",
				created_at: post["created_at"],
				updated_at: post["created_at"],
				# `.attrs` use: http://stackoverflow.com/a/13249551/672403
				data: s2s[post.attrs]
			})
		end
		ActiveRecord::Base.record_timestamps = true
	end
end
