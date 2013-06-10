helpers = %w(laminar l_flickr l_github l_instagram partial l_tumblr l_twitter weather l_vimeo l_youtube)
modules = []
helpers.each do |helper|
	require_relative helper
	modules << helper.classify.constantize
end

App.configure do |app|
	modules.each { |mod| app.helpers mod }
end
