App.configure do |app|
	app.get "/initialize/:service" do
		case params[:service]
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
			# Serialize `request_token` to disk, because any `app.set` or `session`
			# only applies to the Unicorn worker handling this request, which
			# probably won't be the same one to handle the post-auth redirect.
			File.open("#{params[:service]}_token.yaml", "w") { |f| f.write request_token.to_yaml }
		end

		if authorize_url
			redirect authorize_url
		else
			erb "Try again.", { layout: :layout, layout_engine: :haml }
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
		request_token = YAML.load open("#{params[:service]}_token.yaml").read

		case params[:service]
		when "github"
			response = LGithub.client.get_token(params[:code],
				redirect_uri: ENV["GITHUB_AUTHORIZE_URL"])
			token = response.token
		when "instagram"
			response = Instagram.get_access_token(params[:code],
				redirect_uri: ENV["INSTAGRAM_AUTHORIZE_URL"])
			token = response.access_token
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
		end
	end
end
