class Activity < ActiveRecord::Base
	default_scope where(is_private: false).
			order("activities.updated_at DESC, activities.id DESC")
	serialize :data, ActiveRecord::Coders::Hstore

	# will_paginate
	self.per_page = 100

	def for_json recurse=true
		data = self.attributes

		# if recurse
		# 	data.delete "location_id"
		# 	data.delete "user_id"

		# 	data["location"] = self.location.for_json(false)
		# 	data["place"] = self.location.place.for_json(false)
		# 	data["user"] = self.user.for_json(false)
		# else
		# 	data["place_id"] = self.location.place_id
		# end

		data
	end
end
