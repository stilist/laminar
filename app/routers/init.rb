files = Dir["app/routers/*.rb"].map do |path|
	basename = File.basename path, ".rb"
	reject = /(init)/

	basename unless basename =~ reject
end.compact
files.each { |file| require_relative file }
