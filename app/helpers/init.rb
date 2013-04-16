helpers = %w(laminar l_flickr l_instagram partial twttr weather l_vimeo)
modules = []
helpers.each do |helper|
	require_relative helper
	modules << helper.classify.constantize
end

App.configure do |app|
	modules.each { |mod| app.helpers mod }
end
