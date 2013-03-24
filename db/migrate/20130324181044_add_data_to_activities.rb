class AddDataToActivities < ActiveRecord::Migration
	def change
		add_column :activities, :data, :hstore

		add_hstore_index :activities, :data
	end
end
