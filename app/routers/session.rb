App.configure do |app|
	app.get "/login" do
		status 200
		haml :"_login", layout: :"layouts/login"
	end

	app.post "/login" do
		user = User.where(handle: params[:handle]).first

		status_code = user && user.authenticate(params[:password]) ? 200 : 401

		content_type :json
		if status_code == 200
			body({ data: {}, status: status_code }.to_json)

			session[:login] = User.generate_key
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
