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
		when "instagram"
			response = Instagram.get_access_token(params[:code],
				redirect_uri: ENV["INSTAGRAM_AUTHORIZE_URL"])
			"<code>export INSTAGRAM_CLIENT_KEY=#{response.access_token}</code>"
		end
	end
end
