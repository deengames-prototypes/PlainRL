require "classes/entities/Item"

class Armour < Item

	require "classes/modules/ValuableObject"
	include ValuableObject

	# don't call it repository. Will overwrite item.
	@@armours = []

	attr_accessor :defense, :subtype, :cost
	
	def initialize(name, subtype, defense, symbol, quantity = 1, identified = false)
		self.name = name
		self.subtype = subtype
		self.defense = defense
		self.symbol = symbol
		self.quantity = quantity
		self.identified = identified
		recalculate_cost
	end
	
	def scrap_metal
		to_return = self.defense / 5
		to_return = 1 if to_return == 0
		return to_return
	end
	
	def recalculate_cost
		self.cost = (self.defense + 1) * (self.defense + 1) * 2 * 10
	end	
	
	def self.armours
		@@armours
	end
	
	# same as Weapons
	def self.find(name)
		Armour.armours.each do |a|
			if a.name.upcase == name.upcase
				return a
			end
		end
		return nil
	end
	
	def self.weakest
		to_return = Armour.armours[0]
		
		Armour.armours.each do |a|
			to_return = a if a.defense < to_return.defense
		end
		
		to_return.identified = true
		return to_return
	end
	
	def self.random_armour
		to_return = Copier.create_deep_copy(Armour.armours[rand(Armour.armours.length)])
		
		# Individual pieces vary up to 25%		
		to_return.defense += (rand(to_return.defense) * 0.25).to_i
		to_return.recalculate_cost # because we changed damage
		return to_return
	end
	
	def modifier
		return self.defense
	end
	
	def custom_sort_order
		return "#{self.class} #{self.subtype} #{self.defense} #{self.name}"
	end
end