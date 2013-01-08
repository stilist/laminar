class CreateSources < ActiveRecord::Migration
	def change
		create_table :sources do |t|
			t.string :name, null: false
			t.string :url
			t.timestamps
		end

		add_column :entities, :source_id, :integer
	end
end
