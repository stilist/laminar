App.configure do |app|
	app.get "/initialize/:service" do
		case params[:service]
		when "fitbit"
			request_token = LFitbit.client.request_token

			authorize_url = "http://www.fitbit.com/oauth/authorize?oauth_token=#{request_token.token}"
		when "foursquare"
			authorize_url = LFoursquare.authorize_client.auth_code.authorize_url(redirect_uri: ENV["FOURSQUARE_AUTHORIZE_URL"])
		when "kiva"
			request_token = LKiva.client.get_request_token(oauth_callback: ENV["KIVA_AUTHORIZE_URL"])

			scopes = %w(access user_anon_lender_loans user_loan_balances).join ","
			authorize_url = request_token.authorize_url << "&response_type=code&client_id=#{ENV["KIVA_API_KEY"]}&scope=#{scopes}&oauth_callback=#{ENV["KIVA_AUTHORIZE_URL"]}"
		when "moves"
			scopes = %w(activity location).join "%20"
			authorize_url = "https://api.moves-app.com/oauth/v1/authorize?response_type=code&client_id=#{ENV["MOVES_API_KEY"]}&scope=#{scopes}"
		when "soundcloud"
			authorize_url = LSoundcloud.authorize_client.authorize_url scope: "non-expiring"
		when "tumblr"
			request_token = LTumblr.oauth_request_token

			authorize_url = request_token.authorize_url
		when "withings"
			consumer_token = Withings::Api::ConsumerToken.new ENV["WITHINGS_API_KEY"], ENV["WITHINGS_API_SECRET"]

			request_token_response = Withings::Api.create_request_token consumer_token, ENV["WITHINGS_AUTHORIZE_URL"]
			request_token = request_token_response.request_token

			authorize_url = request_token_response.authorization_url
		end

		if request_token
			session["#{params[:service]}_token".to_sym] = request_token
		else
			puts "*** didn't save request token for #{params[:service]}"
		end

		if authorize_url
			redirect authorize_url
		else
			erb "Unknown service. Try again.", { layout: :layout, layout_engine: :haml }
		end
	end

	app.get "/authorize/:service" do
		output = get_output params

		erb output, { layout: :layout, layout_engine: :haml }
	end

	app.post "/authorize/:service" do
		output = get_output params

		erb output, { layout: :layout, layout_engine: :haml }
	end

	private

	def get_output params={}
		request_token = session["#{params[:service]}_token".to_sym]

		case params[:service]
		when "fitbit"
			response = LFitbit.client.authorize(request_token.token,
					request_token.secret, { oauth_verifier: params[:oauth_verifier] })

			out = "<code>export FITBIT_CLIENT_KEY=#{response.token} FITBIT_CLIENT_SECRET=#{response.secret}</code>"
		when "foursquare"
			response = LFoursquare.authorize_client.auth_code.get_token(params[:code], redirect_uri: ENV["FOURSQUARE_AUTHORIZE_URL"])
			token = response.token
		when "github"
			response = LGithub.client.get_token(params[:code],
				redirect_uri: ENV["GITHUB_AUTHORIZE_URL"])
			token = response.token
		when "kiva"
			access_token = request_token.get_access_token(oauth_verifier: params[:oauth_verifier])

			out = "<code>export KIVA_CLIENT_KEY=#{access_token.token} KIVA_CLIENT_SECRET=#{access_token.secret}</code>"
		when "moves"
			data = LMove.get_access_token params[:code]

			out = "<code>export WITHINGS_CLIENT_KEY=#{data["access_token"]}</code>"
		when "instagram"
			response = Instagram.get_access_token(params[:code],
				redirect_uri: ENV["INSTAGRAM_AUTHORIZE_URL"])
			token = response.access_token
		when "soundcloud"
			token = LSoundcloud.get_access_token params[:code]
		when "tumblr"
			response = request_token.get_access_token(oauth_verifier: params[:oauth_verifier])
			token = response.token
		when "withings"
			consumer_token = Withings::Api::ConsumerToken.new ENV["WITHINGS_API_KEY"], ENV["WITHINGS_API_SECRET"]
			access_token_response = Withings::Api.create_access_token request_token,
					consumer_token, ENV["WITHINGS_USER"]
			access_token = access_token_response.access_token

			out = "<code>export WITHINGS_CLIENT_KEY=#{access_token.key} WITHINGS_CLIENT_SECRET=#{access_token.secret}</code>"
		end

		if token
			"<code>export #{params[:service].upcase}_CLIENT_KEY=#{token}</code>"
		elsif out
			out
		else
			""
		end
	end
end
