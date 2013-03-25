class AddIsPrivateToActivities < ActiveRecord::Migration
	def change
		add_column :activities, :is_private, :boolean, default: false
	end
end
