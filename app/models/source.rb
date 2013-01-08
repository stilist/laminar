class Source < ActiveRecord::Base
	has_many :entities

	def for_json recurse=true
		data = self.attributes

		if recurse
			data["entities"] = self.entities.for_json false
		else
			data["entity_ids"] = self.entity_ids
		end

		data
	end
end
