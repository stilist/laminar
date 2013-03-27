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

		newest = Activity.where(activity_type: "post").where(source: "twitter").first
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
