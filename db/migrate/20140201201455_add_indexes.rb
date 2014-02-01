class AddIndexes < ActiveRecord::Migration
	def change
		add_index :activities, :updated_at

		add_index :geolocations, :arrived_at
		add_index :geolocations, :departed_at

		add_index :weather_observations, :updated_at
	end
end
