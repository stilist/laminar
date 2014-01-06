App.configure do |app|
	app.get "/login" do
		if session[:login]
			redirect "/"
		else
			status 200
			haml :"_login", layout: :"layouts/login"
		end
	end

	app.post "/login" do
		user = User.where(handle: params[:handle]).first

		status_code = user && user.authenticate(params[:password]) ? 200 : 401

		content_type :json
		if status_code == 200
			session[:login] = User.generate_key

			{ data: {}, status: status_code }.to_json
		else
			halt 401, {}.to_json
		end
	end

	app.post "/logout" do
		session[:login] = nil

		content_type :json
		body({ data: {}, status: 200 }.to_json)
	end
end
