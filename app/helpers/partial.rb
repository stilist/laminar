module Partial
	def partial view, variables={}
		haml view.to_sym, { layout: false }, variables
	end
end
