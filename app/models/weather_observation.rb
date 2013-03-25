class WeatherObservation < ActiveRecord::Base
	default_scope order("weather_observations.updated_at DESC, weather_observations.id DESC")
	serialize :data, ActiveRecord::Coders::Hstore

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
