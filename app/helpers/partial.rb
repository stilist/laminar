module Partial
	def partial view, variables={}
		layout = variables.delete(:layout) || false

		haml view.to_sym, { layout: layout }, variables
	end
end
