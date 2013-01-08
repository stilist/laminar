class App < Sinatra::Base
	register Sinatra::Synchrony
	register Sinatra::StaticAssets
	register Sinatra::RespondTo

	require_relative "helpers/page_out"
	helpers Sinatra::PageOut

	configure do
		set :root, File.dirname(__FILE__)

		template_path = File.join(App.root, "assets/javascripts/app/templates")
		templates = {}
		Dir.chdir(template_path) do
			Dir.glob("*.hamlbars").each do |path|
				# e.g. `["foo" => "{{foo}}"]`
				name = path.split(".")[0]
				templates.merge!({ name => IO.read(path) })
			end
		end
		set :templates, Hash[templates]

		# Kill ActiveRecord's default of wrapping `Foo`'s JSON with `"foo"` key
		ActiveRecord::Base.include_root_in_json = false
	end
	configure :staging, :production do
		set :haml, { ugly: true }
	end

	# http://stackoverflow.com/a/5030173/672403
	includes = %w(models routers)
	includes.each { |include| require_relative "#{include}/init" }
end
