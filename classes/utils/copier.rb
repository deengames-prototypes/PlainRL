class Copier
	def self.create_deep_copy(object)
		Marshal::load(Marshal.dump(object))
	end  
end