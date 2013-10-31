class Game
	attr_accessor :globals
	
	require "Singleton"
	include Singleton
	
	def initialize
		self.globals = {}
	end
	
	# a necessary evil of serializing and deserializing instances.
	def set_from(g)
		g.instance_variables.each do |x|
			self.instance_variable_set(x, g.instance_variable_get(x))
		end
	end
	
	def set_global(key, value)
		self.globals[key] = value
	end
	
	def get_global(key)
		return self.globals[key]
	end
	
	def remove_global(key)
		self.globals.delete(key)
	end
end