class App < Sinatra::Base
	register Sinatra::Synchrony
	register Sinatra::StaticAssets
	register Sinatra::RespondTo

	require_relative "helpers/page_out"
	helpers Sinatra::PageOut

	# https://gist.github.com/1872516
	def self.get_connection
		return App.db if App.respond_to? :db
		db = URI.parse(ENV["MONGOHQ_URL"] || ENV["MONGO_URL"] || "")
		db_name = db.path.gsub /^\//, ""
		connection = Mongo::Connection.new(db.host, db.port).
				db(db_name, :pool_size => 5, :timeout => 5)
		connection.authenticate(db.user, db.password) unless (db.user.nil? || db.user.nil?)
		connection
	end

	def self.get_templates
		template_path = File.join(App.root, "assets/javascripts/app/templates")
		templates = {}

		Dir.chdir(template_path) do
			Dir.glob("*.hamlbars").each do |path|
				name = path.split(".")[0]
				# e.g. `["foo" => "bar {{baz}} quux"]`
				templates.merge!({ name => IO.read(path) })
			end
		end

		puts " * #{templates.length} template(s)"

		templates
	end

	configure do
		set :db, self.get_connection
		set :collection, App.db.collection("laminar")
		set :haml, { ugly: true }
		set :root, File.dirname(__FILE__)
		set :templates, self.get_templates
	end

	puts " * #{App.collection.count} item(s)"

	# http://stackoverflow.com/a/5030173/672403
	includes = %w(routers)
	includes.each { |include| require_relative "#{include}/init" }
end
