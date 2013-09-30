class Contact < ActiveRecord::Base
	has_many :contact_methods
	has_and_belongs_to_many :parsed_activities
end
