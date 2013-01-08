class CreateEntityTypes < ActiveRecord::Migration
	def change
		create_table :entity_types do |t|
			t.string :name, null: false
			t.timestamps
		end

		add_column :entities, :entity_type_id, :integer
	end
end
