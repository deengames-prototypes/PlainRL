class Inventory

	require "Singleton"
	include Singleton
	
	attr_accessor :contents
	
	def initialize
		self.contents = []
	end
	
	def is_full?
		return self.contents.length >= Globals.inventory_capacity
	end
	
	def has_n_of_item?(item, n)
		if has_item?(item)
			item = get_item(item)
			return item.quantity >= n
		else
			return false
		end
	end
	
	def get_item(item)
		self.contents.each do |i|
			if item.is_a?(Item) && i.name == item.name && i.class == item.class
				return i if i.is_a?(Ammo) && i.damage == item.damage
				return i if i.is_a?(RangeWeapon) && i.range == item.range
				return i if i.is_a?(Weapon) && i.damage == item.damage
				return i if i.is_a?(Armour) && i.defense == item.defense
				return i if !i.is_a?(Ammo) && !i.is_a?(RangeWeapon) && !i.is_a?(Weapon) && !i.is_a?(Armour) && i.name == item.name
			elsif item.is_a?(String)
				return i if i.name == item
			end
		end
		
		return nil
	end
	
	def has_item?(item)
		return !get_item(item).nil?
	end
	
	def remove(item, n = 1)
		self.contents.each do |i|
			if (item.is_a?(Item) && i == item) || (item.is_a?(String) && i.name == item)
				raise "Not enough of #{item} to remove #{n}" if i.quantity < n
				i.quantity -= n;
				break
			end
		end
		
		self.contents.delete_if {|i| i.quantity == 0 }
		reassign_keys_and_sort #keeps us always sorted by name; keys assigned by name
	end
	
	def remove_all(item)
		to_remove = nil
		
		self.contents.each do |i|
			if (item.is_a?(Item) && i == item) || (item.is_a?(String) && i.name == item)
				to_remove = i
				break
			end
		end
		
		self.contents.delete(to_remove)
		reassign_keys_and_sort #keeps us always sorted by name; keys assigned by name
		return to_remove
	end
	
	def add(item)
		added = false
		if !has_item?(item)
			self.contents << item
		else
			self.contents.each do |i|
				if item.class == i.class && item.name == i.name
					i.quantity += item.quantity if item.class != Weapon && item.class != Armour && item.class != RangeWeapon && item.class != Ammo
					i.quantity += item.quantity if item.class == Ammo && item.damage == i.damage
					i.quantity += item.quantity if item.class == RangeWeapon && item.range == i.range
					i.quantity += item.quantity if item.class == Weapon && item.damage == i.damage
					i.quantity += item.quantity if item.class == Armour && item.defense == i.defense
				end
			end
		end
		
		reassign_keys_and_sort #keeps us always sorted by name; keys assigned by name
	end
	
	def reassign_keys_and_sort
		next_key = 1
		self.contents.sort! {|a,b| a.custom_sort_order <=> b.custom_sort_order }.each do |i|
			i.key = next_key;
			next_key += 1
		end
	end
	
	def get_item_for_key(key)
		self.contents.each do |i|
			if i.key.to_s == key.to_s
				return i
			end
		end
		return nil
	end
end
