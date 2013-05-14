App.configure do |app|
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
		end

		"<code>export #{params[:service].upcase}_CLIENT_KEY=#{token}</code>"
	end
end
