class Entity < ActiveRecord::Base
	require "digest/sha1"

	serialize :data, JSON

	belongs_to :source
	belongs_to :entity_type

	before_create :set_hash_key

	def for_json recurse=true
		data = self.attributes

		if recurse
			data.delete "source_id"
			data.delete "entity_type_id"

			data["source"] = self.source.for_json false
			data["entity_type"] = self.entity_type.for_json false
		end

		data
	end

	private

	def set_hash_key
		self.hash_key = Digest::SHA1.hexdigest(rand(100000000000000000000000000000).to_s)
	end
end
