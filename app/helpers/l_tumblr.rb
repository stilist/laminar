module LTumblr
	def self.client
		Tumblr.configure do |config|
			config.consumer_key = ENV["TUMBLR_API_KEY"]
			config.consumer_secret = ENV["TUMBLR_API_SECRET"]
			config.oauth_token = ENV["TUMBLR_CLIENT_KEY"]
			config.oauth_token_secret = "access_token_secret"
		end
	end

	def self.oauth_client
		@client ||= OAuth::Consumer.new(ENV["TUMBLR_API_KEY"], ENV["TUMBLR_API_SECRET"], {
			site: "http://www.tumblr.com",
			request_token_path: "/oauth/request_token",
			authorize_path: "/oauth/authorize",
			access_token_path: "/oauth/access_token",
			http_method: :post
		})
	end

	def self.oauth_request_token
		self.oauth_client.get_request_token(oauth_callback: ENV["TUMBLR_AUTHORIZE_URL"])
	end
end