require "sinatra/base"

module Sinatra
	# = Sinatra::JsonApi
	#
	# <tt>Sinatra::JsonApi</tt> is an extension meant for use with Backbone-style
	# apps that use the backend strictly as an API. It assumes that full page
	# loads should serve only to bootstrap the frontend application.
	#
	# == Usage
	#
	# Note: depends on the `sinatra-respond_to` gem.
	#
	# === Classic Application
	#
	# To use the extension in a classic application:
	#
	#     require "sinatra"
	#     register Sinatra::RespondTo
	#     require "sinatra/json_api"
	#
	#     # Application code
	#
	# === Modular Application
	#
	# To use the extension in a modular application:
	#
	#     require "sinatra/base"
	#     require "sinatra/json_api"
	#
	#     class MyApp < Sinatra::Base
	#       register Sinatra::RespondTo
	#       helpers Sinatra::JsonApi
	#
	#       # Application code
	#     end
	#
	# This will add the +page_out+ method to the application/class scope.  You
	# can choose not to register the extension, but instead of calling
	# +page_out+, you will need to call <tt>Sinatra::JsonApi.page_out</tt>.
	#
	module JsonApi
		# Assuming ActiveRecord is set up with a `User` table, and a HAML file
		# named `layout.haml` that loads Backbone etc.
		#
		#     enable :sessions
		#
		#     get "/users" do
		#       page_out User.all
		#     end
		#
		#     app.get "/users/:id" do
		#       user = User.find_by_id params[:id]
		#       page_out user, ->{ 404 unless user }
		#     end
		#
		#     app.post "/" do
		#       if @user
		#         page_out user
		#       else
		#         user = User.by_email params[:email]
		#         session[:user] = user.id if user && user.password == params[:password]
		#         page_out user, ->{ 401 unless user }
		#       end
		#     end
		#
		#     before do
		#       @user = User.find_by_id session[:user]
		#       unauthorized = !@user && request.path != "/"
		#       page_out(nil, 401) if unauthorized
		#     end
		#
		# If the user has not authenticated, attempting to access `/users` or
		# `/users/3` will result in a 401 Unauthorized error and a blank response.
		# Once the user has authenticated, `/user` will give all known users;
		# `/users/3` will give back the `User` record or a 404 error.
		#
		# This example also demonstrates several convenient features:
		# 1. `data` and `status_code` can be `nil`
		# 2. Passing a lambda for the `status_code` argument--`/users/3` determines
		#    the HTTP status code by whether the `User` record exists.
		#
		# == Other notes
		#
		# `page_out` attempts to call `for_json` on whatever is passed to `data`.
		# Simply define a `for_json` method in the ActiveRecord model and return
		# a `Hash` with the desired fields. Convenient for filtering out passwords
		# or embedding associations.
		def page_out data={}, status_code=200, extras={}
			output = case
				when data.respond_to?(:for_json) then data.for_json
				when data.class == Array || data.class == WillPaginate::Collection
					data.map { |i| i.respond_to?(:for_json) ? i.for_json : i }
				else data
			end

			# Process `status_code` if it's a lambda. Need `... || 200` in case
			# lambda returns `nil`.
			status_code = (status_code.call || 200) if status_code.respond_to? :call

			# 401 Unauthorized
			# 403 Forbidden
			if [401, 403].include? status_code
				respond_to do |format|
					format.js { halt_json status_code }
					format.json { halt_json status_code }
					format.html { redirect "/" }
				end
			else
				respond_to do |format|
					format.js { send_json output, status_code }
					format.json { send_json output, status_code }
					format.html { send_page output, status_code, extras }
				end
			end
		end

		private

		def halt_json status_code=400
			content_type :json
			halt status_code, {}.to_json
		end

		def send_json data={}, status_code=200
			content_type :json
			status status_code
			body({ data: data, status: status_code }.to_json)
		end

		def prerender_data data, extras={}
			type = data["activity_type"]
			source = data["source"]

			template = App.templates["#{type}_#{source}"] ||
					App.templates["#{source}"] || App.templates["generic"] || ""

			locals = data.merge({ "template" => template, "extras" => extras })

			partial template, { layout: :template_wrapper, locals: locals }
		end

		def send_page data, status_code=200, extras={}
			output = ""

			if status_code != 404
				if data.class == Array || data.class == WillPaginate::Collection
					data.each { |item| output << prerender_data(item, extras) }
				elsif data != {}
					output << prerender_data(data, extras)
				end
			end

			status status_code
			# Can't render with `haml` because `output` is HTML at this point
			erb output, { layout: :layout, layout_engine: :haml }
		end
	end

	helpers JsonApi
end
