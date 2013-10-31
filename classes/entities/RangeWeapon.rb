require "classes/entities/Item"

class RangeWeapon < Item
	
	require "classes/modules/ValuableObject"
	include ValuableObject

	# don't call it repository. Will overwrite item.
	@@range_weapons = []

	attr_accessor :range, :cost, :subtype, :ammo
	
	def initialize(name, subtype, range, symbol, quantity = 1, identified = false)
		self.name = name
		self.subtype = subtype
		self.range = range
		self.symbol = symbol
		self.quantity = quantity
		self.identified = identified
		self.ammo = nil
		
		self.recalculate_cost
	end
	
	def scrap_metal
		to_return = self.range / 3
		to_return = 1 if to_return == 0
		return to_return
	end
	
	def recalculate_cost
		self.cost = self.range * self.range * self.range * 2 * 15
	end
	
	def self.range_weapons
		@@range_weapons
	end
	
	def full_name
		return "#{self.name} #{self.subtype}"
	end
	
	def self.find(target)
		RangeWeapon.range_weapons.each do |w|
			if w.full_name.upcase == target.full_name.upcase
				return w
			end
		end
		return nil
	end
	
	def self.random_range_weapon(min=[1, Dungeon.instance.floor_num - 1].max, max=[Dungeon.instance.floor_num + 1, RangeWeapon.range_weapons.size].min)
		# on floor X, get weapons [x-1 .. x+1]
		index = rand(max - min) + min
		
		if (index < 0)
			index = 0
		elsif index >= RangeWeapon.range_weapons.length
			index = RangeWeapon.range_weapons.length - 1
		end
		
		to_return = Copier.create_deep_copy(RangeWeapon.range_weapons[index])

		# Individual pieces vary up to 25%		
		to_return.range += (rand(to_return.range) * 0.25).to_i
		to_return.recalculate_cost # because we changed range
		return to_return
	end
	
	def custom_sort_order
		# The "C" puts it below Weapons
		return "C#{self.class} #{self.subtype} #{self.range} #{self.name}"
	end
end
