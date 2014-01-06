class CreateUsers < ActiveRecord::Migration
	def change
		create_table :users do |t|
			t.string :handle
			t.string :display_name
			t.string :password_digest
			t.timestamps
		end

		add_index :users, :handle
	end
end
