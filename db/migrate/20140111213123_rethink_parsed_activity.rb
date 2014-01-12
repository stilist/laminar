class RethinkParsedActivity < ActiveRecord::Migration
	def change
		drop_table :parsed_activities

		add_column :activities, :parsed_data, :text
	end
end
