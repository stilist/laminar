class CreateParsedActivity < ActiveRecord::Migration
	def change
		create_table :parsed_activities do |t|
			t.references :activity
			# will be used as JSON--created this migration with Active Record 3.x;
			# native JSON support introduced in AR 4.0
			t.text :data
			t.timestamps
		end

		create_table :contacts_parsed_activities, id: false do |t|
			t.references :contact
			t.references :parsed_activity
		end
	end
end
