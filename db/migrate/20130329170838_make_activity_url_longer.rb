class MakeActivityUrlLonger < ActiveRecord::Migration
	def up
		change_column :activities, :url, :text, limit: 1000
	end

	def down
		raise ActiveRecord::IrreversibleMigration, "Can't make 'url' shorter"
	end
end
