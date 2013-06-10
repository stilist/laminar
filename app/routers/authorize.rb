App.configure do |app|
	app.get "/initialize/:service" do
		case params[:service]
		when "tumblr"
			request_token = LTumblr.oauth_request_token

			# Serialize `request_token` to disk, because any `app.set` or `session`
			# only applies to the Unicorn worker handling this request, and who knows
			# if it'll be the same one to handle the post-auth redirect.
			File.open("tumblr_token.yaml", "w") { |f| f.write request_token.to_yaml }

			authorize_url = request_token.authorize_url
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
			request_token = YAML.load open("tumblr_token.yaml").read

			response = request_token.get_access_token(
				oauth_verifier: params[:oauth_verifier]
			)
			token = response.token
		end

		if token
			"<code>export #{params[:service].upcase}_CLIENT_KEY=#{token}</code>"
		end
	end
end
