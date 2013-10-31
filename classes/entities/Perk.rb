class Perk
	attr_accessor :name, :description, :level
	
	@@repository = []
	
	def initialize(name, description, level)
		self.name = name
		self.description = description
		self.level = level.to_i
	end
	
	def self.repository
		@@repository
	end
	
	def self.find(name)
		Perk.repository.each do |p|
			if (p.name.upcase == name.upcase)
				return p
			end
		end
		return nil
	end
end