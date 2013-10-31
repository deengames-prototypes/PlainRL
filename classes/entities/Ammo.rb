require "classes/entities/Weapon"

class Ammo < Weapon

	require "classes/modules/ValuableObject"
	include ValuableObject

	# don't call it repository. Will overwrite item.
	@@ammo = []
	
	def self.ammo
		@@ammo
	end
	
	def self.find(target)
		Ammo.ammo.each do |a|
			if a.full_name.upcase == target.full_name.upcase
				return a
			end
		end
		return nil
	end
	
	def self.random_ammo()
		
		index = rand(Ammo.ammo.length)
		
		if (index < 0)
			index = 0
		elsif index >= Ammo.ammo.length
			index = Ammo.ammo.length - 1
		end
		
		to_return = Copier.create_deep_copy(Ammo.ammo[index])
		return to_return
	end
	
	def custom_sort_order
		# The "D" puts it below everthing but items
		return "D#{self.class} #{self.subtype} #{self.damage} #{self.name}"
	end
end