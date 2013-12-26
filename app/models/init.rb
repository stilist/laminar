App.configure do |app|
	app.register Sinatra::ActiveRecordExtension

	# https://github.com/janko-m/sinatra-activerecord
	database_url = ENV["DATABASE_URL"] || ""
	app.set(:database, database_url) unless database_url == ""
end

files = Dir["app/models/*.rb"].map do |path|
	basename = File.basename path, ".rb"
	reject = /(init)/

	basename unless basename =~ reject
end.compact
files.each { |file| require_relative file }
