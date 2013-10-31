class Globals

	require "Singleton"
	include Singleton

	@@SCREEN_WIDTH = 80
	@@STATUS_BAR_HEIGHT = 4
	@@SIDE_WINDOW_WIDTH = 20
	
	# +1 so it overlaps into the sidebar and shares that edge
	@@STATUS_BAR_WIDTH = @@SCREEN_WIDTH - @@SIDE_WINDOW_WIDTH
	@@SCREEN_HEIGHT = 25
	
	@@MAP_WIDTH = @@SCREEN_WIDTH;
	@@MAP_HEIGHT = @@SCREEN_HEIGHT;
	
	@@MAP_SCREEN_WIDTH = @@SCREEN_WIDTH - @@SIDE_WINDOW_WIDTH
	@@MAP_SCREEN_HEIGHT = @@SCREEN_HEIGHT - @@STATUS_BAR_HEIGHT
	@@SIDE_WINDOW_HEIGHT = @@SCREEN_HEIGHT

	@@MONSTER_ITEM_DROP = 10 #10%
	@@MONSTER_WEAPON_DROP = 4 #4%
	
	@@TRADER_ITEMS_FOR_SALE = 10
	
	@@REUSES_OF_ARMOUR = 6
	@@REUSES_OF_WEAPONS = 3
	@@REUSES_OF_RANGE_WEAPONS = 10
	
	@@TESTING = false
	
	def self.farrier_items_ammo_quantity
		return 100
	end
	
	def self.inventory_capacity
		return 16
	end
	
	def self.points_per_forge_level
		return 20
	end
	
	def self.max_forge_level
		return 20
	end
	
	def self.points_per_skill_level
		return 100
	end
	
	def self.point_per_weapon_skill_level
		return 100
	end
	
	def self.levels_per_sight_up
		return 10
	end
	
	def self.reuses_of_range_weapons
		return @@REUSES_OF_RANGE_WEAPONS
	end
	
	def self.reuses_of_weapons
		@@REUSES_OF_WEAPONS
	end
	
	def self.reuses_of_armour
		@@REUSES_OF_ARMOUR
	end
	
	def self.trader_items_for_sale
		@@TRADER_ITEMS_FOR_SALE
	end
	
	def self.map_screen_width
		@@MAP_SCREEN_WIDTH
	end
	
	def self.map_screen_height
		@@MAP_SCREEN_HEIGHT
	end
	
	def self.map_width
		@@MAP_WIDTH
	end
	
	def self.map_height
		@@MAP_HEIGHT
	end
	
	def self.screen_width
		@@SCREEN_WIDTH
	end
	
	def self.screen_height
		@@SCREEN_HEIGHT
	end
	
	def self.side_window_width
		@@SIDE_WINDOW_WIDTH
	end
	
	def self.side_window_height
		@@SIDE_WINDOW_HEIGHT
	end
	
	def self.status_bar_width
		@@STATUS_BAR_WIDTH
	end
	
	def self.status_bar_height
		@@STATUS_BAR_HEIGHT
	end
	
	def self.testing
		@@TESTING
	end
	
	def self.testing=(value)
		@@TESTING = value
	end
	
	def self.monster_item_drop
		@@MONSTER_ITEM_DROP
	end
	
	def self.monster_weapon_drop
		@@MONSTER_WEAPON_DROP
	end
end
