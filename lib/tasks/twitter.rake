# `static_tweets_local` processes the data from Twitter's archive

namespace :twitter do
	task :favorites do ; LTwitter.get_favorites end
	task :backfill_favorites do ; LTwitter.get_favorites true end

	task :tweets do ; LTwitter.get_tweets end
	task :backfill_tweets do ; LTwitter.get_tweets true end

	task :static_tweets_local do
		items = LTwitter.process_local_data
		Laminar.put_static_data ENV["TWITTER_TWEETS_FILENAME"], items
	end

	task :static_tweets_remote do
		items = Laminar.get_static_data ENV["TWITTER_STATIC_TWEETS_URL"]
		Laminar.add_items "twitter", "post", items
	end
end
