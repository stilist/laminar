class AddOriginalIdToActivities < ActiveRecord::Migration
	def up
		add_column :activities, :original_id, :string

		Activity.reset_column_information

		begin
			ActiveRecord::Base.record_timestamps = false
			Activity.all.each do |a|
				if a["data"]["id"]
					a.original_id = a["data"]["id"]
					a.save
				end
			end
		ensure
			ActiveRecord::Base.record_timestamps = true
		end
	end

	def down
		remove_column :activities, :original_id
	end
end
