class CreateEntities < ActiveRecord::Migration
	def change
		create_table :entities do |t|
			t.string :hash_key, null: false, length: 20
			t.text :data, null: false
			t.timestamps
		end
	end
end
