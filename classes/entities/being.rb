class Being	

	require "classes/modules/VisibleObject"
	include VisibleObject
	
	attr_accessor :current_health, :total_health, :strength, :agility, :toughness, :is_seen
	
	def is_alive?
		return self.current_health > 0;
	end
	
	def try_to_move(x, y)
		d = Dungeon.instance
		if (x.nil? || y.nil? || x < 0 || y < 0 || x > d.width || y > d.height)
			raise "Cannot move off the map or have negative/nil x or y (X, Y = #{x}, #{y}; Map with = #{Globals.map_width}, #{Globals.map_height}; I am #{self})"
		end
		if d.is_walkable?(x, y)
			self.x = x
			self.y = y
		end
	end
end