class CreateContacts < ActiveRecord::Migration
	def change
		create_table :contacts do |t|
			t.string :name
			t.boolean :is_company, default: false
			t.timestamps
		end

		create_table :contact_methods do |t|
			t.references :contact
			t.string :display
			t.string :uri
			t.string :medium
			t.boolean :is_active, default: true
			t.timestamps
		end
	end
end
