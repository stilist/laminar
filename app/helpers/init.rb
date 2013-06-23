helpers = Dir["app/helpers/*.rb"].map do |path|
	basename = File.basename(path, ".rb")
	reject = /(init|json_api|page_out)/

	basename unless basename =~ reject
end.compact

modules = []
helpers.each do |helper|
	require_relative helper
	modules << helper.classify.constantize
end

App.configure do |app|
	modules.each { |mod| app.helpers mod }
end
