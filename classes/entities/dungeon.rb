class Dungeon
	require "Singleton"
	include Singleton
	
	require "classes/entities/Being"
	require "classes/utils/Copier"
	require "classes/entities/Monster"
	require "classes/entities/RevivingMonster"
	require "classes/entities/HiveQueen"
	require "classes/entities/Wall"
	require "classes/entities/Door"
	require "classes/entities/Player"
	require "classes/entities/Stairs"
	require "classes/entities/Room"
	require "classes/entities/Person"
	require "classes/entities/Item"
	require "classes/gui/StatusBar"
	require "classes/gui/MainWindow"
	require "classes/utils/extendedMath"
	require "classes/utils/XYIndexedCollection"
	require "classes/Globals"
	
	attr_accessor :width, :height
	attr_accessor :walls, :monsters, :stairs, :doors, :items, :people, :vortex
	attr_accessor :floor_num, :start_time
	
	@@old_floor_num = 0
	
	def generate_next_floor
		@@old_floor_num = self.floor_num
		
		if self.floor_num.nil?
			self.floor_num = 1
		else
			self.floor_num += 1
			Dungeon.instance.start_time = Time.new if (self.floor_num == 1)
		end
		generate
		
		SideWindow.instance.show_floor
	end
	
	def generate_previous_floor
		@@old_floor_num = self.floor_num
		self.floor_num -= 1
		
		
		if self.floor_num > 0
			generate
		else
			generate_town
		end
		
		SideWindow.instance.show_monster_count
	end
	
	def clear_los_cache
		@los_cache.clear
	end
	
	def generate
		@los_cache = XYIndexedCollection.new if @los_cache.nil?
		
		self.width = Globals.map_width
		self.height = Globals.map_height
		clear_everything
		
		if (self.floor_num < 30)
			if (self.floor_num % 5 == 0)
				build_arena
			else
				build_catacomb
			end
		else
			build_final_floor
		end
		
		randomly_place_player
		place_vortex
		add_quest_stuff
		
		Player.instance.last_fired_at = nil
		SideWindow.instance.show_monster_count
		
		show_boss_message
	end
	
	def build_walled_border
		(0..self.width - 1).each do |x|
			walls.add(Wall.new(x, 0))
			walls.add(Wall.new(x, self.height - 1))
		end
		
		(0..self.height - 1).each do |y|
			walls.add(Wall.new(0, y))
			walls.add(Wall.new(self.width - 1, y))
		end
	end

	def give_item_to_player
		if self.is_item?(Player.instance.x, Player.instance.y)
			item = self.item_at(Player.instance.x, Player.instance.y)
			
			if !Player.instance.inventory.is_full? || Player.instance.inventory.has_item?(item)
				Player.instance.inventory.add(item)
				self.items.delete(item)
				StatusBar.instance.show_get(item)
			else
				StatusBar.instance.show_message("You have too many items. (Max is #{Globals.inventory_capacity} unique items) [more]")
				InputHelper.read_char
			end
		end
	end
	
	def generate_stairs
		randomly_place_stairs(false) # down
		randomly_place_stairs(true) if self.floor_num > 0 # up
	end
	
	def randomly_place_player

		down_stairs = 0
		up_stairs = 1
		
		if (@@old_floor_num.nil? || self.floor_num > @@old_floor_num)
			stairs_to_use = up_stairs
		else
			stairs_to_use = down_stairs
		end
		
		stairs_to_use = 0 if stairs[stairs_to_use].nil?
		
		x = self.stairs[stairs_to_use].x - 1
		y = self.stairs[stairs_to_use].y - 1
		
		# start from top-left; sweep right and down
		if !is_clear?(x, y)
			x += 1
			if !is_clear?(x, y)
				x += 1
				if !is_clear?(x, y)
					y += 1
					if !is_clear?(x, y)
						y += 1
						if !is_clear?(x, y)
							x -= 1
							if !is_clear?(x, y)
								x -= 1
								if !is_clear?(x, y)
									y -= 1
									if !is_clear?(x, y)
										y -= 1
										if !is_clear?(x, y)
											raise "Cannot find empty spot adjacent to stairs."
										end
									end
								end
							end
						end
					end
				end
			end
		end	
		
		Player.instance.x = x
		Player.instance.y = y
	end
	
	def generate_town
		self.width = Globals.map_width / 2
		self.height = Globals.map_height / 2
		
		clear_everything
		build_walled_border
		generate_stairs
		randomly_place_player
		add_townspeople
		place_vortex
		
		Player.instance.game_time += (Time.new - Dungeon.instance.start_time) if !Dungeon.instance.start_time.nil?
		Dungeon.instance.start_time = nil
	end
	
	def generate_monsters(min, max)
		# generate n monsters in random rooms
		# use monsters in the range [floor_num ... floor_num + 2]
		# generate a boss, too, if we need to
		extra = 0
		extra = rand(3) if self.floor_num > 2
		num_monsters = rand((max - min)) + min
		min_index = [self.floor_num - 1, Monster.repository.length - 1].min # index base = 0, floor num base = 1
		max_index = [min_index + 3, Monster.repository.length - 1].min + extra # [n ... n+2] + 0-2
		
		while num_monsters > 0
			monster = Monster.random_monster(min_index, max_index)
			monster = Copier.create_deep_copy(monster)
			x = 0
			y = 0
			
			while !is_clear?(x, y)
				x = rand(self.width)
				y = rand(self.height)
			end
			monster.x = x
			monster.y = y
			
			self.monsters.add(monster)
			num_monsters -= 1
		end
		
		boss = Monster.bosses[floor_num]
		if !boss.nil?
			x = 0
			y = 0
			while !is_clear?(x, y)
				x = rand(self.width)
				y = rand(self.height)
			end
			boss.x = x
			boss.y = y
			self.monsters.add(boss)
		end
				
		self.generate_hyperweeds if self.is_hyperweed_floor?
		self.generate_invisible_monsters if self.is_invisible_monster_floor?
	end
	
	def is_hyperweed_floor?
		# 20F, and then every N floors
		return self.floor_num >= 20 && self.floor_num % 5 == 0 && self.floor_num < 30
	end
	
	def is_invisible_monster_floor?
		return self.floor_num >= 26 && self.floor_num < 30
	end
	
	def generate_hyperweeds
		# use average of three monsters for stats
		m = self.monsters.to_array
		
		hp = 0
		str = 0
		agi = 0
		tgh = 0
		
		(0..2).each do |i|
			hp += m[i].total_health
			str += m[i].strength
			agi += m[i].agility
			tgh += m[i].toughness
		end
		
		hp *= 2
		str /= 3
		agi /= 3
		tgh /= 3
		revive_percent = 10
		
		(0..10 + rand(5)).each do |i|
			r = RevivingMonster.new("Hyper Weed", hp, str, agi, tgh, "W", revive_percent)
			xy = generate_random_clear_x_y
			r.x = xy["x"]
			r.y = xy["y"]
			self.monsters.add(r)
			Player.instance.killed.delete("Hyper Weed")
		end
	end
	
	def generate_invisible_monsters
		# 10-50%
		percent = rand(45) + 10
		self.monsters.to_array.each do |m|
			if rand(100) <= percent && !m.name.downcase.include?("weed")
				raw_name = m.name[m.name.index(" ") + 1, m.name.length]
				m.name = "invisible #{raw_name}"
				m.visible = false
			end
		end
	end

	def is_in_line_of_sight?(x1, y1, x2, y2)
		return @los_cache.get(x2, y2)  if x1 == Player.instance.x && y1 == Player.instance.y && @los_cache.is_at?(x2, y2)

		los = line_of_sight(x1, y1, x2, y2)
		los.each do |p|
			if p.x == x2 && p.y == y2 && p.is_occluded == false
				@los_cache.add_at(x2, y2, true) if x1 == Player.instance.x && y1 == Player.instance.y
				return true 
			end
		end
		
		@los_cache.add_at(x2, y2, false) if x1 == Player.instance.x && y1 == Player.instance.y
		return false
	end
	
	def line_of_sight(x1, y1, x2, y2)
		points = []
		
		points << Point.new(x2, y2) # add target always
		
		# return if adjacent
		dist = Math.sqrt(((x2 - x1)**2) + ((y2 - y1)**2))
		if dist < 1.5 # adjacent; 1.4142135623731 represents a diagonal adjacency
			points << Point.new(x2, y2)
			return check_occlusion_and_sort_by_distance(x1, y1, points)
		end
		
		d = Dungeon.instance
		
		slope = ((y2 - y1) / (x2 - x1 - 0.00000)) # need precisionfrom_x = [self.x, x].min
				
		from_x = [x1, x2].min # exclude from item
		from_y = [y1, y2].min # exclude from item
		
		to_x = [x1, x2].max
		to_y = [y1, y2].max
		
		if (slope < 0)
			# flip from_y and to_y
			temp = from_y
			from_y = to_y
			to_y = temp
			slope = -slope
			
			from_x += 1 if from_x != to_x
			from_y -= 1 if from_y != to_y
			to_x -= 1 if from_x != to_x
		else
			#exclude player/target
			from_x += 1 if from_x != to_x
			from_y += 1 if from_y != to_y
			to_x -= 1 if from_x != to_x
			to_y -= 1 if from_y != to_y
		end
		
		infinity = 1.0/0
		
		if (slope == infinity || slope == -infinity)
			x = from_x # same as to_x
			to_y += 1 if from_y > to_y # slope == -infinity doesn't work?!
			([from_y, to_y].min .. [from_y, to_y].max).each do |y|
				#return false unless self.is_clear?(x, y)
				points << Point.new(x, y)
			end
		elsif (slope <= 1)
			y = from_y
			(from_x .. to_x).each do |x|
				#return false unless self.is_clear?(x, y)
				points << Point.new(x, y)
				y += slope if to_y >= from_y
				y -= slope if to_y < from_y
				y += slope if y < to_y && from_y > to_y # don't go above player; ignore positive-slope case
			end
		else
			if (from_y > to_y)
				temp = from_y
				from_y = to_y
				to_y = temp
				slope = -slope
				x = to_x
				
				from_y += 1
			else
				x = from_x
			end
			
			(from_y .. to_y).each do |y|
				#return false unless self.is_clear?(x, y)
				points << Point.new(x, y)
				x += 1/slope if to_x >= from_x
				x -= 1/slope if x < from_x && from_y >= to_y
				x -= 1/slope if x < from_x
			end
		end

		#return true
		return check_occlusion_and_sort_by_distance(x1, y1, points)
	end
	
	def is_wall?(x, y)
		self.walls.is_at?(x, y)
	end
	
	def is_stairs_down?(x, y)
		self.stairs.each do |s|
			if (x == s.x && y == s.y && s.is_up == false)
				return true
			end
		end
		return false
	end
	
	def is_stairs_up?(x, y)
		self.stairs.each do |s|
			if (x == s.x && y == s.y && s.is_up == true)
				return true
			end
		end
		return false
	end
	
	def is_stairs?(x, y)
		return is_stairs_down?(x, y) || is_stairs_up?(x, y)
	end
	
	def get_stairs_down
		self.stairs.each do |s|
			return s if s.is_up == false
		end
		return nil
	end
	
	def is_vortex_at?(x, y)
		return !self.vortex.nil? && self.vortex.x == x && self.vortex.y == y
	end
	
	def get_monster(x, y)
		self.monsters.get(x, y)
	end
	
	def is_monster?(x, y)
		return self.monsters.is_at?(x, y) && self.monsters.get(x, y).is_alive?
	end
	
	def is_walkable?(x, y)
		return !is_wall?(x, y) && !is_monster?(x, y) && !is_player?(x, y) && !is_closed_door?(x, y) && !is_person?(x, y)
	end
	
	def is_closed_door?(x, y)
		self.doors.each do |d|
			if d.x == x && d.y == y && d.is_open == false
				return true
			end
		end
		return false
	end
	
	def is_item?(x, y)
		self.items.each do |i|
			if i.x == x && i.y == y
				return true
			end
		end
		return false
	end
	
	def is_person?(x, y)
		self.people.each do |p|
			if p.x == x && p.y == y
				return true
			end
		end
		return false
	end
	
	def person_at(x, y)
		self.people.each do |p|
			if p.x == x && p.y == y
				return p
			end
		end
		return nil
	end
	
	# item OR weapon
	def item_at(x, y)
		self.items.each do |i|
			if i.x == x && i.y == y
				return i
			end
		end
		return nil
	end
	
	def open_door(x, y)
		self.doors.each do |d|
			if d.x == x && d.y == y && d.is_open == false
				d.is_open = true
			end
		end
	end
	
	def is_clear?(x, y)
		return is_walkable?(x, y) #&& !is_stairs?(x, y) # stairs don't apply to Line of Sight
	end
	
	def is_player?(x, y)
		if Player.instance.x == x && Player.instance.y == y
			return true
		else
			return false
		end
	end
	
	def try_to_close_door(x, y)
		self.doors.each do |d|
			if d.x == x && d.y == y && d.is_open == true
				d.is_open = false
			end
		end
	end
	
	def remove_monster(monster)
		self.monsters.delete(monster)
	end
	
	def generate_adjacent_clear_x_y(x, y)
		# Try all around
		# start from top-left; sweep right and down
		x -= 1
		y -= 1
		
		if !self.is_clear?(x, y)
			x += 1
			if !self.is_clear?(x, y)
				x += 1
				if !self.is_clear?(x, y)
					y += 1
					if !self.is_clear?(x, y)
						y += 1
						if !self.is_clear?(x, y)
							x -= 1
							if !self.is_clear?(x, y)
								x -= 1
								if !self.is_clear?(x, y)
									y -= 1
									if !self.is_clear?(x, y)
										y -= 1
										if !self.is_clear?(x, y)
											return nil
										end
									end
								end
							end
						end
					end
				end
			end
		end
		
		return Point.new(x, y)
	end
	
	def generate_random_clear_x_y
		x = 0
		y = 0
			
		while !is_clear?(x, y)
			x = rand(self.width)
			y = rand(self.height)
		end
		
		h = Hash.new
		h["x"] = x
		h["y"] = y
		
		return h
	end
	
	private
	
	def check_occlusion_and_sort_by_distance(x1, y1, points)
		to_return = []
		occluded = false
		
		# sort by distance to origin (x1, y1)
		points.sort {|a, b| ExtendedMath.distance_between(x1, y1, a.x, a.y) <=> ExtendedMath.distance_between(x1, y1, b.x, b.y)}.each do |p|
			if occluded == true
				to_return << Point.new(p.x.to_i, p.y.to_i, true)
			else
				to_return << Point.new(p.x.to_i, p.y.to_i)
			end

			occluded = true if !self.is_clear?(p.x.to_i, p.y.to_i)			
		end
		return Point.uniq(to_return)
	end
	
	def show_boss_message
		self.monsters.to_array.each do |b|
			if b.is_boss == true
				if !b.name.include?("Tentacle")
					StatusBar.instance.show_message("#{b.name} is here! The stairs disappear! [more]") unless self.floor_num == 30
					InputHelper.read_char unless self.floor_num == 30
				end
				self.get_stairs_down.visible = false unless self.floor_num == 30
			end
		end
	end
	
	def is_full_of_walls?(x, y, width, height)
		(x..x+width).each do |i|
			(y..y+height).each do |j|
				if !is_wall?(i, j)
					return false
				end
			end
		end
		return true
	end
	
	def carve_out(x, y, width, height)
		(0..width).each do |i|
			(0..height).each do |j|
				self.walls.delete_at(i + x, j + y)
			end
		end
	end
	
	def build_tunnels(x, y, width, height)

		to_x = 0
		to_y = 0
		
		# non-wall that's not the current room
		while is_wall?(to_x, to_y) || (to_x >= x && to_x <= x + width && to_y >= y && to_y <= y + height)
			to_x = rand(self.width)
			to_y = rand(self.height)
		end
		
		from_x = rand(width) + x
		from_y = rand(height) + y
	
		tunnel_to(from_x, from_y, to_x, to_y)
		#self.doors << Door.new(from_x, from_y)
		#self.doors << Door.new(to_x, to_y)
	end
	
	def tunnel_to(from_x, from_y, to_x, to_y)
		([from_x, to_x].min .. [from_x, to_x].max).each do |i|
			self.walls.delete_at(i, from_y)
		end
	
		([from_y, to_y].min .. [from_y, to_y].max).each do |i|
			self.walls.delete_at(to_x, i)
		end
	end
	
	def add_doors(num_doors)
		(1..num_doors).each do |i|
			x = rand(self.width)
			y = rand(self.height)
			
			while is_wall?(x, y) || !((is_wall?(x-1, y) && is_wall?(x+1, y)) || (is_wall?(x, y-1) && is_wall?(x, y+1)))
				x = rand(self.width)
				y = rand(self.height)
			end
			
			self.doors << Door.new(x, y)
		end
	end
	
	def randomly_place_stairs(is_up = false)
		x = self.width / 2
		y = self.height / 2
		
		while x == 0 || x == self.width - 1 || y == 0 || y == self.height - 1 || !is_clear?(x, y) ||
		# don't generate stairs on stairs/vortex
		is_stairs?(x, y) || is_vortex_at?(x, y) ||
		# not adjacent to a wall
		is_wall?(x, y - 1) || is_wall?(x, y + 1) ||
		is_wall?(x + 1, y) || is_wall?(x - 1, y) ||
		# not adjacent to a door
		is_closed_door?(x, y - 1) || is_closed_door?(x, y + 1) ||
		is_closed_door?(x + 1, y) || is_closed_door?(x - 1, y)
		
			x = rand(self.width)
			y = rand(self.height)
		end
		
		self.stairs << Stairs.new(x, y, is_up)
	end
	
	def place_vortex
		return if Player.instance.vortex_floor.nil? || (Player.instance.vortex_floor != Dungeon.instance.floor_num && Dungeon.instance.floor_num > 0)
		
		x = Player.instance.x
		y = Player.instance.y
		
		while !is_clear?(x, y)
			x = rand(self.width)
			y = rand(self.height)
		end
		
		self.vortex = Vortex.new(x, y)
	end
	
	def build_arena
		clear_everything
		build_walled_border
		build_center_room
		Player.instance.x = self.stairs[1].x
		Player.instance.y = self.stairs[1].y
		generate_monsters(30, 60)
	end
	
	def build_final_floor
		clear_everything
		self.width = (Globals.map_width * 0.7).to_i
		self.height = (Globals.map_height * 0.8).to_i
		build_walled_border
		self.stairs = [Stairs.new(self.width / 2, self.height / 2, true)] #stairs up
		Player.instance.x = self.width / 2
		Player.instance.y = self.height / 2
		
		StatusBar.instance.show_message("You see the Hive Queen, the source of all monsters! [more]")
		InputHelper.read_char
		
		# 25x health, 2-4x as fast, 4x as tough ... she's a toughy!
		queen = HiveQueen.new
		
		xy = generate_random_clear_x_y
		queen.x = xy["x"]
		queen.y = xy["y"]
		self.monsters.add(queen)
		
		last_one = queen
		
		# 10-20 eggs
		1.upto(rand(10) + 10) do |i|
			xy = generate_random_clear_x_y
			
			# Generate eggs 0-5 squares from existing eggs
			while ExtendedMath.distance_between(xy["x"], xy["y"], last_one.x, last_one.y) > 8
				xy = generate_random_clear_x_y
			end
			
			egg = MonsterEgg.new
			egg.x = xy["x"]
			egg.y = xy["y"]
			last_one = egg
			self.monsters.add(egg)
		end
		
		# add monster-queen; generates eggs, runs away from you
		# add eggs; hatch in N turns. depends on str+agi+toughness.
		
	end
	
	def build_center_room
		# quarter of the map, centered
		room_width = self.width / 4
		room_height = self.height / 4
		room_x = (self.width - room_width) / 2
		room_y = (self.height - room_height) / 2
		
		(room_x .. room_x + room_width).each do |x|
			walls.add(Wall.new(x, room_y))
			walls.add(Wall.new(x, room_y + room_height))
		end
		
		(room_y .. room_y + room_height).each do |y|
			walls.add(Wall.new(room_x, y))
			walls.add(Wall.new(room_x + room_width, y))
		end
		
		flip = rand(2)
		if flip == 0
			# horizontal doors
			y = room_y + (room_height / 2)
			walls.delete_at(room_x, y)
			walls.delete_at(room_x + room_width, y)
			self.doors << Door.new(room_x, y)
			self.doors << Door.new(room_x + room_width, y)
		else
			# vertical doors
			x = room_x + (room_width / 2)
			walls.delete_at(x, room_y)
			walls.delete_at(x, room_y + room_height)
			self.doors << Door.new(x, room_y)
			self.doors << Door.new(x, room_y + room_height)
		end
		
		corner = rand(4)
		case corner
			when 0 # top left
				x = 2
				y = 2
			when 1 # top right
				x = self.width - 3
				y = 2
			when 2 # bottom right
				x = self.width - 3
				y = self.height - 3
			when 3 # bottom left
				x = 2
				y = self.height - 3
		end
		
		self.stairs << Stairs.new(self.width / 2, self.height / 2, false)
		self.stairs << Stairs.new(x, y, true)
		
	end
	
	def build_catacomb		
		(0..self.width - 1).each do |x|
			(0..self.height - 1).each do |y|
				walls.add(Wall.new(x, y))
			end
		end
		
		rooms = []
		
		# Random number of rooms
		num_rooms = rand(12) + 8; #8-20 looks good
		min_width = 4;
		min_height = 2;
		max_width = 8;
		max_height = 4;
		first_room = true;
		
		num_doors = num_rooms
		
		while (num_rooms > 0) do
			width = rand(max_width - min_width) + min_width;
			height = rand(max_width - min_height) + min_height;
			# don't be RIGHT on the edge of the map
			room_x = rand(self.width - width - 2) + 1
			room_y = rand(self.height - height - 2) + 1
			
			if is_full_of_walls?(room_x, room_y, width, height)
				carve_out(room_x, room_y, width, height)
				if first_room == false
					build_tunnels(room_x, room_y, width, height)
				end
				first_room = false
				num_rooms -= 1;
			end
		end
		
		add_doors(num_doors)
		
		generate_stairs
		generate_monsters(10, 15)
	end
	
	def clear_everything
		self.walls = XYIndexedCollection.new
		self.monsters = XYIndexedCollection.new
		@los_cache = XYIndexedCollection.new # cache of where we can see LOS-wise; X, Y is object XY, from player position
		self.stairs = []
		self.doors = []
		self.items = []
		self.people = []
	end
	
	def add_townspeople
		add_healer
		add_materials_armourer
		add_trader
		add_quest_maker
		add_farrier
		add_blacksmith if Game.instance.get_global("rescued_blacksmith") == true
	end
	
	def add_farrier
		x = rand(self.width - 1)
		y = rand(self.height)
		
		while !is_clear?(x, y) && !is_clear?(x + 1, y)
			x = rand(self.width)
			y = rand(self.height)
		end
		
		self.people << Person.new(x, y, "Farrier", "Person.talk_to_farrier", COLOR_BLUE)
		Person.generate_farrier_items unless RangeWeapon.range_weapons.length == 0 || Ammo.ammo.length == 0
	end
	
	def add_healer
		#heals HP to max
		x = rand(self.width)
		y = rand(self.height)
		
		while !is_clear?(x, y)
			x = rand(self.width)
			y = rand(self.height)
		end
		
		self.people << Person.new(x, y, "Healer", "Person.heal_player", COLOR_CYAN)
	end
	
	def add_blacksmith
		x = rand(self.width)
		y = rand(self.height)
		
		while !is_clear?(x, y)
			x = rand(self.width)
			y = rand(self.height)
		end
		
		self.people << Person.new(x, y, "Blacksmith", "Person.talk_to_blacksmith", COLOR_RED)
	end
	
	def add_trader
		# buys anything. has random items for sale
		x = rand(self.width - 1)
		y = rand(self.height)
		
		while !is_clear?(x, y) && !is_clear?(x + 1, y)
			x = rand(self.width)
			y = rand(self.height)
		end
		
		self.people << Person.new(x, y, "Trader", "Person.talk_to_trader", COLOR_MAGENTA)
		Person.trader_items = Person.generate_trader_items unless Weapon.weapons.length == 0
		
	end
	
	def add_materials_armourer
		# give him materials, he makes armour when you come back.
		x = rand(self.width)
		y = rand(self.height)
		
		while !is_clear?(x, y)
			x = rand(self.width)
			y = rand(self.height)
		end
		
		self.people << Person.new(x, y, "Armour Maker", "Person.talk_to_armour_maker", COLOR_GREEN)
	end
	
	def add_quest_maker
		x = rand(self.width)
		y = rand(self.height)
		
		while !is_clear?(x, y)
			x = rand(self.width)
			y = rand(self.height)
		end
		
		self.people << Person.new(x, y, "Quest Maker", "Person.talk_to_quest_maker", COLOR_YELLOW)
	end
	
	def add_quest_stuff

		randomly_place_monster(Monster.bosses["Trollus"]) if self.floor_num == 3 && !Player.instance.killed?(Monster.bosses["Trollus"])
		
		if self.floor_num == 6 && !Player.instance.killed?(Monster.bosses["Slime-X"])
			(0.. (rand(2) + 3)).each do |i|
				randomly_place_monster(Monster.bosses["Slime-X"])
			end
		end
		
		if (self.floor_num == 8 && Game.instance.get_global("rescued_blacksmith") == false)
			xy = generate_random_clear_x_y
			self.people << Person.new(xy["x"], xy["y"], "Blacksmith", "Person.rescue_blacksmith", COLOR_RED)
		end
		
		if (self.floor_num == 13 && !Player.instance.killed?(Monster.bosses["Decalotupus"]))
		
			self.monsters.clear
			
			num_tentacles = Game.instance.get_global("num_tentacles")
			# They grow ...
			num_tentacles += 3
			num_tentacles = Game.instance.set_global("num_tentacles", num_tentacles)
			
			(1 .. num_tentacles).each do |i|
				randomly_place_monster(Monster.bosses["Decalotupus Tentacle"])
			end
			
			randomly_place_monster(Monster.bosses["Decalotupus"])
		end
		
		randomly_place_monster(Monster.bosses["Aarij the Mage"]) if self.floor_num == 23 && !Player.instance.killed?(Monster.bosses["Aarij the Mage"])
	end
		
	def randomly_place_monster(monster)
		coordinates = generate_random_clear_x_y
		x = coordinates["x"]
		y = coordinates["y"]
		
		# generate bosses 10+ steps away
		while monster.is_boss == true && Math.sqrt(((x - Player.instance.x)**2) + ((y - Player.instance.y)**2)) <= 10
			coordinates = generate_random_clear_x_y
			x = coordinates["x"]
			y = coordinates["y"]
		end
		
		monster.x = x
		monster.y = y
		self.monsters.add(Copier.create_deep_copy(monster))
	end
end
