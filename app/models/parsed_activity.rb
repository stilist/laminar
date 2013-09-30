class ParsedActivity < ActiveRecord::Base
	belongs_to :activity
	has_and_belongs_to_many :contacts
end
