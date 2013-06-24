namespace :lastfm do
	task :authorize do
		client = LLastfm.client
		token = client.auth.get_token

		puts "Open this URL in your browser to authorize Laminar:"
		puts "http://www.last.fm/api/auth/?api_key=#{ENV["LASTFM_API_KEY"]}&token=#{token}"
		puts
		puts "Hit return/enter after granting access"
		STDIN.gets

		client_key = client.auth.get_session(token: token)["key"]
		puts "export LASTFM_CLIENT_KEY=#{client_key}"
	end

	task :plays do ; LLastfm.get_data end
	task :backfill_plays do ; LLastfm.get_data true end
end
