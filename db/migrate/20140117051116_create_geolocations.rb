class CreateGeolocations < ActiveRecord::Migration
	def change
		create_table :geolocations do |t|
			t.references :activity
			t.boolean :is_path, default: false
			t.string :location_type
			t.string :name
			t.decimal :lat, { precision: 10, scale: 6 }
			t.decimal :lng, { precision: 10, scale: 6 }
			t.decimal :altitude, { precision: 15, scale: 6 }
			t.datetime :arrived_at
			t.datetime :departed_at

			t.timestamps
		end
	end
end
