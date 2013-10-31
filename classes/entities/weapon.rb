require "classes/entities/Item"

class Weapon < Item

	require "classes/modules/ValuableObject"
	include ValuableObject

	# don't call it repository. Will overwrite item.
	@@weapons = []

	attr_accessor :damage, :cost, :subtype
	
	def initialize(name, subtype, damage, symbol, quantity = 1, identified = false)
		self.name = name
		self.subtype = subtype
		self.damage = damage
		self.symbol = symbol
		self.quantity = quantity
		self.identified = identified
		self.recalculate_cost
	end
	
	def scrap_metal
		to_return = self.damage / 10
		to_return = 1 if to_return == 0
		return to_return
	end
	
	def recalculate_cost
		self.cost = self.damage * self.damage * 2 * 10
	end
	
	def self.weapons
		@@weapons
	end
	
	def full_name
		return "#{self.name} #{self.subtype}"
	end
	
	def self.find(target)
		Weapon.weapons.each do |w|
			if w.full_name.upcase == target.full_name.upcase
				return w
			end
		end
		return nil
	end
	
	def self.weakest
		to_return = Weapon.weapons[0]
		
		Weapon.weapons.each do |w|
			to_return = w if w.damage < to_return.damage
		end
		
		to_return.identified = true
		return to_return
	end
	
	def self.random_weapon(min=[1, Dungeon.instance.floor_num - 1].max, max=[Dungeon.instance.floor_num + 1, Weapon.weapons.size].min)
		# on floor X, get weapons [x-1 .. x+1]
		index = rand(max - min) + min
		
		if (index < 0)
			index = 0
		elsif index >= Weapon.weapons.length
			index = Weapon.weapons.length - 1
		end
		
		to_return = Copier.create_deep_copy(Weapon.weapons[index])

		# Individual pieces vary up to 25%		
		to_return.damage += (rand(to_return.damage) * 0.25).to_i
		to_return.recalculate_cost # because we changed damage
		return to_return
	end
	
	def modifier
		return self.damage
	end
	
	def custom_sort_order
		# The "B" puts it below Armour
		return "B#{self.class} #{self.subtype} #{self.damage} #{self.name}"
	end
end
