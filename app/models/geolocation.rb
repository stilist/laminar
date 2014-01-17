class Geolocation < ActiveRecord::Base
	belongs_to :activity

	default_scope { order("geolocations.arrived_at DESC, geolocations.departed_at DESC, geolocations.id DESC") }

	def for_json recurse=true ; self.attributes end
end
