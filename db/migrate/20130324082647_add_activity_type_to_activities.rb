class AddActivityTypeToActivities < ActiveRecord::Migration
	def change
		add_column :activities, :activity_type, :string
	end
end
