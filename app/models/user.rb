class User < ActiveRecord::Base
	attr_accessible :password
	has_secure_password

	def self.generate_key
		require "digest/sha1"

		login_key = Digest::SHA1.hexdigest(rand(100000000000000000000000000000).to_s)
	end
end
