class App < Sinatra::Base
	register Sinatra::Synchrony
	register Sinatra::StaticAssets
	register Sinatra::RespondTo

	require_relative "helpers/json_api"
	helpers Sinatra::JsonApi

	def self.get_templates
		template_path = File.join(root, "views/partials")
		templates = {}

		Dir.chdir(template_path) do
			Dir.glob("*.haml").each do |path|
				name = path.split(".")[0]
				# Allows for `templates["foo"] || nil`, vs a series of `.include?`
				templates.merge!({ name => "partials/#{name}" })
			end
		end

		puts " * #{templates.length} template(s)"

		templates
	end

	configure do
		set :root, File.dirname(__FILE__)
		set :templates, self.get_templates

		# Kill ActiveRecord's default of wrapping `Foo`'s JSON with `"foo"` key
		ActiveRecord::Base.include_root_in_json = false
	end
	configure :staging, :production do
		set :haml, { ugly: true }
	end

	# http://stackoverflow.com/a/5030173/672403
	# `uploaders` comes before `models` due to dependencies
	includes = %w(helpers uploaders models routers)
	includes.each { |include| require_relative "#{include}/init" }
end
