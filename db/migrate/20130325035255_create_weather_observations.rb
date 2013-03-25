class CreateWeatherObservations < ActiveRecord::Migration
	def change
		create_table :weather_observations do |t|
			t.string :source
			t.hstore :data
			t.decimal :lat, { precision: 10, scale: 6 }
			t.decimal :lng, { precision: 10, scale: 6 }
			t.timestamps
		end

		add_hstore_index :weather_observations, :data
	end
end
