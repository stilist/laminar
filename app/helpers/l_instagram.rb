module LInstagram
	def self.client
		if ENV["INSTAGRAM_CLIENT_KEY"]
			puts "yay"
			Instagram.client(access_token: ENV["INSTAGRAM_CLIENT_KEY"])
		end
	end
end
