class MainWindow

	require "ncurses"
	
	require "Singleton"
	include Singleton
	
	require "classes/Globals"
	require "classes/entities/Dungeon"
	require "classes/entities/Skill"
	require "classes/entities/Weapon"
	require "classes/utils/LoaderSaver"
	require "classes/gui/MockWindow"
	require "classes/gui/GuiHelper"
	require "classes/gui/Window"
	
	@foliage = ""
	@foliage_colours = ""
	
	attr_accessor :window
	
	def initialize
		if Globals.testing == false
			self.window = Window.new(Globals.map_screen_width, Globals.map_screen_height, 0, 0)
			@foliage = ""
		else
			self.window = MockWindow.new
		end
	end
	
	def show_console_log
		self.window.clear
		draw_border
		
		messages = StatusBar.instance.messages
		self.window.setpos(2, 2)
		self.window.addstr("Messages (most-recent first):")
		self.window.setpos(3, 4)
		
		
		messages = messages.reverse
		
		while (self.window.cury < 18)
			m = messages[0]
			messages.delete_at(0)
			self.window.setpos(self.window.cury + 1, 4)
			self.window.addstr(m)
		end
		
		self.window.refresh
	end
	
	def show_blacksmith_menu
		self.window.clear
		draw_border
		
		self.window.setpos(2, 2)
		self.window.addstr("I'm the blacksmith! Ach! I work with metals!")
		
		self.window.setpos(3, 2)
		self.window.addstr("What would ye like me to do, laddie?")
		
		self.window.setpos(5, 4)
		self.window.addstr("[D]ismantle something into scrap metal")
		self.window.setpos(6, 4)
		self.window.addstr("[F]orge two pieces of equipment into one")
		
		points = Game.instance.get_global("num_items_fused")
		level = [points / Globals.points_per_forge_level, Globals.max_forge_level].min
		points %= Globals.points_per_forge_level
		
		points_string = " : #{points}/#{Globals.points_per_forge_level}" if level < Globals.max_forge_level
		
		self.window.setpos(8, 2)
		self.window.addstr("Blacksmith Level: #{level}#{points_string}")
		self.window.refresh
	end
	
	def show_game_over
		
		(0 .. Globals.map_screen_height / 2).each do |i|
			blacken_square((Globals.map_screen_height / 2) - i)
			sleep(0.05)
		end
		
		self.window.clear
		# center text
		self.window.setpos(Globals.map_screen_height / 2, Globals.map_screen_width / 2 - 9)
		self.window.addstr("*** GAME OVER! ***")
		self.window.refresh
	end
	
	def show_trader_inquiry
		self.show_inventory
		StatusBar.instance.ask_which_materials
	end
	
	def show_game_backstory
		self.window.clear
		self.window.color_set(COLOR_WHITE)
		self.window.attroff(A_BOLD)
		draw_border		
		self.window.setpos(2, 2)

		GuiHelper.show_padded_message(self.window, "\"Praised be God! Our message to his Prophet made it!\" Tears leak from his eyes. \"Many of our fellow townsmen died from the monsters. We're safe from the beasts, it seems.\" He glances at the stairs (purple). \"Now, let me tell you of our plight: monsters appeared, from the masjid; as we were building our third floor up, there was an explosion. It was magic; almost certainly, it was was Aarij who did it. Curse him!\" he shouts. \"He chose to dabble in magic, which brings only evil. Now, the  masjid is a place of evil magic; and it goes down--many floors down. It's a place of evil, and monsters; monsters attack us, and have taken one of our townsfolk, and eaten many others. Please, help us. You were sent for us.\"")
		self.window.setpos(self.window.cury + 1, 2)
		GuiHelper.show_padded_message(self.window, "\"Make your preperations, and return when you're ready. Aarij must be stopped; I fear he's summoned some foul, evil creature that's creating these monsters. And beware--the dungeon is ever-changing, never the same. [more]")

		self.window.refresh
		InputHelper.read_char
	end
	
	def show_endgame
		self.window.clear
		self.window.color_set(COLOR_WHITE)
		draw_border
		
		self.window.attron(A_BOLD)
		self.window.setpos(2, 2)
		self.window.addstr("Your final, crushing blow reduces the Hive Queen into a ")
		self.window.setpos(3, 2)
		self.window.addstr("pile of bloody pulp.")
		self.window.setpos(5, 2)
		self.window.addstr("It's over.")
		self.window.setpos(7, 2)
		self.window.addstr("You retreat from the dungeon, back to the surface.")
		self.window.setpos(9, 2)
		self.window.addstr("The townspeople hail you as a hero; you saved their town.")
		self.window.setpos(11, 2)
		self.window.color_set(COLOR_YELLOW)
		self.window.addstr("Congratulations! You've completed the game!")
		self.window.color_set(COLOR_CYAN)
		self.window.setpos(13, 2)
		self.window.addstr("Please send your feedback to ashes999@yahoo.com.")
		self.window.setpos(14, 2)
		self.window.addstr("Hope you enjoyed it!")
		self.window.setpos(16, 2)
		self.window.color_set(COLOR_WHITE)
		self.window.attroff(A_BOLD)
		self.window.addstr("[Press any key to quit]")
		self.window.refresh
		InputHelper.read_char
	end
	
	def show_character_status
		self.window.clear
		draw_border
		self.window.color_set(COLOR_WHITE)
		self.window.attron(A_BOLD)
		self.window.setpos(2, 2)
		self.window.addstr("Character Status:")
		y = 3
		
		self.window.setpos(y, 4)
		self.window.addstr("Level: #{Player.instance.level}")
		self.window.setpos(y + 1, 4)
		self.window.addstr("EXP: #{Player.instance.experience_points} / #{Player.instance.experience_points_for_next_level}")
		self.window.setpos(y + 2, 4)
		self.window.addstr("Gold: #{Player.instance.gold}")
		
		self.window.setpos(y + 4, 4)
		self.window.addstr("Strength: #{Player.instance.strength}")
		self.window.color_set(COLOR_CYAN)
		self.window.addstr(" Atk: #{(Player.instance.weapon.damage * (Player.instance.current_weapon_skill.level + 1)) + Player.instance.strength}") unless Player.instance.weapon.nil?
		self.window.color_set(COLOR_WHITE)
		self.window.setpos(y + 5, 4)
		self.window.addstr("Toughness: #{Player.instance.toughness} ")
		self.window.color_set(COLOR_YELLOW)
		self.window.addstr(" Def: #{Player.instance.toughness + Player.instance.total_armour_defense}")
		
		self.window.color_set(COLOR_WHITE)
		self.window.setpos(y + 6, 4)
		self.window.addstr("Agility: #{Player.instance.agility}")
		self.window.addstr(" + #{Player.instance.agility_additive.to_i}") if Player.instance.agility_additive > 0
		self.window.setpos(y + 7, 4)
		self.window.addstr("Sight: #{Player.instance.sight}")
				
		if !Player.instance.vortex_floor.nil?
			self.window.setpos(y + 9, 4)
			self.window.addstr("Vortex on #{Player.instance.vortex_floor}F")
		end
		
		self.window.setpos(y + 10, 4)
		if Player.instance.auto_arrow_management == true
			self.window.addstr("Disable")
		else
			self.window.addstr("Enable")
		end
		self.window.addstr(" [A]rrow Management")
		
		self.window.setpos(y + 12, 4)
		total_time = Player.instance.game_time;
		total_time += (Time.new - Dungeon.instance.start_time).to_i if !Dungeon.instance.start_time.nil?
		
		seconds = total_time.to_i
		minutes = seconds / 60
		seconds %= 60
		hours = minutes / 60
		minutes %= 60
		minutes = "0#{minutes}" if minutes < 10
		seconds = "0#{seconds}" if seconds < 10
		
		self.window.addstr("Game time: #{hours}:#{minutes}:#{seconds}")

		self.window.setpos(y + 13, 4)
		self.window.addstr("Saves: #{Game.instance.get_global("num_saves")}")
		
		
		write_menu_item("[a]uto manage arrows", 4, 30)
		write_menu_item("[p]erks", 5, 30)
		write_menu_item("[q]uests", 6, 30)
		write_menu_item("[s]kills", 7, 30)
		write_menu_item("[w]eapon skills", 8, 30)
		
		self.window.refresh
	end
	
	def show_hurt_stars(monsters)
		monsters.each do |m|
			show_hurt_star(m, false) 
		end
		
		self.window.refresh
		sleep(0.05)
	end
	
	def show_arrow_firing(source, destination, num_shots = 1, is_fireball = false, colours = [COLOR_WHITE])
		self.draw
		self.window.attron(A_BOLD)
		path = Dungeon.instance.line_of_sight(source.x, source.y, destination.x, destination.y)
		#steps = path.length
		#total_time = 0.1
		#time_per_step = total_time / steps
		time_per_step = 0.02		
		time_per_step = 0.1 / path.length if time_per_step * path.length > 0.1 # max of 0.1s
		
		colour_index = 0
		
		old_point = Point.new(source.x, source.y)
		char = ""
		
		(1..num_shots).each do |i|
			path.each do |p|
				self.window.color_set(colours[colour_index]) # cycle through colours
				colour_index += 1
				colour_index %= colours.length # cycle through colours
				self.window.setpos(p.y - start_y, p.x - start_x)
				
				if is_fireball == true
					char = "*" 
				else	
					rise = p.y - old_point.y
					run = p.x - old_point.x
					if (run < 0) # right to left
						char = "/" if rise > 0
						char = "\\" if rise < 0
					elsif (run > 0) # left to right
						char = "/" if rise < 0
						char = "\\" if rise > 0
					else
						char = "|"
					end
					char = "-" if rise == 0
				end
				
				self.window.addstr(char)
				self.window.refresh
				sleep(time_per_step)
				self.window.setpos(p.y - start_y, p.x - start_x)
				self.window.addstr(".")
				self.window.refresh
				old_point = p
			end
		end
	end
	
	def show_hurt_star(being, with_delay = true)
		x = being.x - start_x
		y = being.y - start_y
		self.window.color_set(COLOR_RED)
		self.window.attron(A_BOLD)
		self.window.setpos(y, x)
		self.window.addstr("*")
		self.window.refresh unless with_delay == false
		sleep(0.05) unless with_delay == false
	end
	
	def show_egg_hatch_star(monster)
		x = monster.x - start_x
		y = monster.y - start_y
		self.window.color_set(COLOR_CYAN)
		self.window.attron(A_BOLD)
		self.window.setpos(y, x)
		self.window.addstr("*")
		self.window.refresh 
		sleep(0.03) 
	end
	
	def show_trader_items
		self.window.clear	
		draw_border
		self.window.setpos(2, 2)
		self.window.addstr("Here's what I have right now:")
		
		y = 3
		
		items = Person.trader_items
		
		items.each do |i|
			if i.is_a?(RangeWeapon)
				modifier = i.range
			elsif i.is_a?(Weapon) || i.is_a?(Ammo)
				modifier = i.damage
			elsif i.is_a?(Armour)
				modifier = i.defense
			end
			
			self.window.setpos(y, 3)
			self.window.addstr("#{y - 2}) #{i.name} (+#{modifier}): #{i.effective_cost} gold")
			y += 1
		end
		
		y += 2
		
		self.window.setpos(y, 2)
		self.window.addstr("So what do you want? (Type number, press enter) ")
		
		self.window.refresh
	end
	
	def show_farrier_items
		self.window.clear
		draw_border
		self.window.setpos(2, 2)
		self.window.addstr("I'm the local farrier. Here's what I have in stock:")
		
		y = 3		
		
		items = Person.farrier_items
		last_item = items[0]
		
		items.each do |i|
			if i.is_a?(RangeWeapon)
				modifier = i.range
			elsif i.is_a?(Ammo)
				modifier = i.damage
			else #?!
				modifier = nil
			end
			
			self.window.setpos(y, 3)
			
			self.window.addstr("#{y - 2}) ")
			self.window.addstr("#{i.quantity}x ") if i.is_a?(Ammo)
			self.window.addstr("#{i.name} (+#{modifier}): #{i.effective_cost} gold")
			y += 1
			y += 1 if y == 8 # space out from bows/arrows
		end
		
		y += 2
		
		self.window.setpos(y, 2)
		self.window.addstr("So whatchu want? (Type number, press enter) ")
		
		self.window.refresh
	end
	
	def draw(draw_aim_cursor = false, cursor_x = 0, cursor_y = 0)
		if @foliage.length == 0
			@foliage = ""
			@foliage_colours = ""
			(0 ... Globals.map_screen_width * Globals.map_screen_height).each do |i|
				if rand(2) == 0
					@foliage += "&"
				else
					@foliage += "*"
				end
				
				if rand(2) == 0
					@foliage_colours += "0"
				else
					@foliage_colours += "1"
				end
			end
		end
		
		dungeon = Dungeon.instance
		self.window.clear

		self.window.attroff(A_BOLD)
		self.window.color_set(COLOR_WHITE)
		(0..Globals.map_screen_width - 1).each do |x|
			(0..Globals.map_screen_height - 1).each do |y|
				if (x + start_x < Globals.map_width && y + start_y < Globals.map_height) && (Player.instance.has_perk?("omnivision")  || Dungeon.instance.floor_num == 0 || Dungeon.instance.floor_num == 30 || Player.instance.floor_is_in_sight(x + start_x, y + start_y))
					self.window.setpos(y, x)
					if Player.instance.floor_is_in_sight(x + start_x, y + start_y) && (Dungeon.instance.floor_num == 30 || Player.instance.has_perk?("omnivision"))
						self.window.attron(A_BOLD)
					else
						self.window.attroff(A_BOLD)
					end
					
					# draw forest around us
					if Dungeon.instance.floor_num == 0 && (x >= Globals.map_width / 2 || y >= Globals.map_height / 2)
						self.window.color_set(COLOR_GREEN)
						if @foliage_colours[x + (y * Globals.map_screen_width)].chr == "0"
							self.window.attron(A_BOLD)
						else
							self.window.attroff(A_BOLD)
						end
						self.window.addstr(@foliage[x + (y * Globals.map_screen_width)].chr)
					else
						self.window.use_grey
						self.window.addstr(".")
					end
				end
			end
		end

		self.window.attroff(A_BOLD)
		self.window.use_grey
		
		dungeon.walls.to_array.each do |w|
			if Player.instance.is_in_sight(w) || Player.instance.has_perk?("omnivision")
				w.is_seen = true;
			end
			if is_in_range(w, start_x, start_y) && (w.is_seen == true || Dungeon.instance.floor_num == 0 || Dungeon.instance.floor_num == 30)
				self.window.setpos(w.y - start_y, w.x - start_x)
				self.window.addstr("#")
			end
		end
				
		self.window.color_set(COLOR_MAGENTA)
		self.window.attron(A_BOLD) if dungeon.floor_num == 0

		dungeon.stairs.each do |s|
			if Player.instance.is_in_sight(s) || Player.instance.has_perk?("omnivision") || Dungeon.instance.floor_num == 0 || Dungeon.instance.floor_num == 30
				s.is_seen = true;
			end
			if is_in_range(s, start_x, start_y) && s.is_seen == true && s.visible == true
				self.window.setpos(s.y - start_y, s.x - start_x)
				if (s.is_up) then
					self.window.addstr(Stairs.up_symbol)
				else
					self.window.addstr(Stairs.down_symbol)
				end
			end
		end

		self.window.attroff(A_BOLD)
		self.window.color_set(COLOR_YELLOW)
		dungeon.doors.each do |d|
			if Player.instance.is_in_sight(d) || Player.instance.has_perk?("omnivision") || Dungeon.instance.floor_num == 0 || Dungeon.instance.floor_num == 30
				d.is_seen = true;
			end
			if is_in_range(d, start_x, start_y) && d.is_seen == true 
				self.window.setpos(d.y - start_y, d.x - start_x)
				if (d.is_open) then
					self.window.addstr(Door.open_symbol)
				else
					self.window.addstr(Door.close_symbol)
				end
			end
		end
		
		self.window.color_set(COLOR_CYAN)		
		dungeon.items.each do |i|
			if Player.instance.is_in_sight(i) || Player.instance.has_perk?("omnivision") || Dungeon.instance.floor_num == 0 || Dungeon.instance.floor_num == 30
				i.is_seen = true;
				# unlike other things, items must be in sight to be seen
				if is_in_range(i, start_x, start_y) && i.is_seen == true
					# highlight items you don't have
					if Inventory.instance.has_item?(i)
						self.window.attroff(A_BOLD)
					else
						self.window.attron(A_BOLD)
					end
					self.window.setpos(i.y - start_y, i.x - start_x)
					self.window.addstr(i.symbol)
				end
			end
		end
		
		dungeon.monsters.to_array.each do |m|
			if Player.instance.has_perk?("infravision") || Player.instance.is_in_sight(m) || Player.instance.has_perk?("omnivision") || Dungeon.instance.floor_num == 30
				m.is_seen = true if m.visible == true || Player.instance.has_perk?("infravision") || Player.instance.has_perk?("omnivision")
				if m.is_alive? && is_in_range(m, start_x, start_y) && ((m.is_seen == true  && m.visible == true) || Player.instance.has_perk?("infravision"))
				
					# highlight unkilled monsters, and eggs with more than 50% health
					if !Player.instance.killed?(m)
						self.window.attron(A_BOLD)
					else
						self.window.attroff(A_BOLD)
					end
					
					self.window.color_set(COLOR_CYAN)
					if (m.current_health < m.total_health)
						self.window.color_set(COLOR_YELLOW)
					end
					
					if (m.current_health < 0) || ((Player.instance.has_perk?("danger-sense") && (m.damage_in_attack * m.num_attacks) >= 0.25 * Player.instance.total_health) || m.is_boss == true)
						self.window.color_set(COLOR_RED)
					end
					
					# special case: eggs are always white; if at 50% health, they're grey
					if m.name.include?("Egg")
						self.window.color_set(COLOR_WHITE)
						if m.current_health > 0.5 * m.total_health
							self.window.attron(A_BOLD)
						else
							self.window.attroff(A_BOLD)
						end
					end					
					
					self.window.setpos(m.y - start_y, m.x - start_x)
					self.window.addstr(m.symbol)
				end
			end
		end
		
		self.window.attron(A_BOLD)
		dungeon.people.each do |p|
			if is_in_range(p, start_x, start_y) && (Player.instance.is_in_sight(p) || Dungeon.instance.floor_num == 0 || Dungeon.instance.floor_num == 30 || Player.instance.has_perk?("omnivision"))
				self.window.color_set(p.colour)
				self.window.setpos(p.y - start_y, p.x - start_x)
				self.window.addstr(Person.symbol)
			end
		end

		if !dungeon.vortex.nil? && (Dungeon.instance.floor_num == 0 || Player.instance.vortex_floor == Dungeon.instance.floor_num) && (is_in_range(dungeon.vortex, start_x, start_y) ||  Player.instance.has_perk?("omnivision") || Dungeon.instance.floor_num == 30)
			self.window.attron(A_BOLD)
			self.window.color_set(COLOR_BLUE)
			self.window.setpos(dungeon.vortex.y - start_y, dungeon.vortex.x - start_x)
			self.window.addstr(Vortex.symbol)
		end
		
		self.window.attron(A_BOLD)

		if (Player.instance.current_health == Player.instance.total_health)
			self.window.color_set(COLOR_WHITE)
		elsif Player.instance.current_health < Player.instance.total_health && Player.instance.current_health >= (0.5 * Player.instance.total_health)
			self.window.color_set(COLOR_CYAN)
		elsif Player.instance.current_health >= (0.25 * Player.instance.total_health)
			self.window.color_set(COLOR_YELLOW)
		else
			self.window.color_set(COLOR_RED)
		end
		
		self.window.setpos(Player.instance.y - start_y, Player.instance.x - start_x)
		self.window.addstr(Player.instance.symbol)

		if draw_aim_cursor == true
			self.window.setpos(cursor_y - start_y, cursor_x - start_x)
			highlight_route_to(cursor_x, cursor_y, start_x, start_y)
		end
		
		self.window.color_set(COLOR_WHITE)
		self.window.refresh	
	end
	
	def highlight_route_to(x, y, start_x, start_y)
		points = Dungeon.instance.line_of_sight(Player.instance.x, Player.instance.y, x, y)		
		next_int = 1
		destination_occluded = false
		
		points.each do |p|
			if p.is_occluded == true
				self.window.color_set(COLOR_RED) 
				destination_occluded = true
			else
				self.window.color_set(COLOR_WHITE)
			end
			
			self.window.setpos(p.y - start_y, p.x - start_x)
			
			distance_to_point = ExtendedMath.distance_between(p.x, p.y, Player.instance.x, Player.instance.y)
			
			# grey out if out-of-sight
			if distance_to_point <= Player.instance.sight
				self.window.attron(A_BOLD)
			else
				self.window.attroff(A_BOLD)
			end
			
			self.window.color_set(COLOR_RED) if distance_to_point > Player.instance.range_weapon.range
			
			self.window.addstr((next_int % 10).to_s)
			next_int += 1
		end
	end
	
	def close
		self.window.close unless window.nil?
	end
	
	def show_trader_menu
		self.window.clear
		draw_border
		self.window.setpos(2, 2)
		self.window.addstr("Greetings, my friend. I'm a collector of weapons.")
		self.window.setpos(3, 2)
		self.window.addstr("I also buy armour. Would you like to buy or sell?")
		self.window.setpos(5, 2)
		self.window.addstr("(B to buy, S to sell)")
		self.window.refresh
	end
	
	def show_main_menu
		self.window.clear
		draw_full_border
		self.window.attron(A_BOLD)
		
		self.window.color_set(COLOR_BLUE)
		GuiHelper.write_at_center(self.window, 4, "PlainRL")
		
		self.window.color_set(COLOR_WHITE)
		
		GuiHelper.write_at_center(self.window, 6, "-=-=-=-=-=-=-=-=-")
		
		x = GuiHelper.center_x_for(self.window, "[N]ew Game")
		self.window.setpos(8, x)
		self.window.attroff(A_BOLD)
		self.window.addstr("[")
		self.window.attron(A_BOLD)
		self.window.addstr("N")
		self.window.attroff(A_BOLD)
		self.window.addstr("]ew Game")
		
		x = GuiHelper.center_x_for(self.window, "[L]oad Game")
		self.window.setpos(9, x)
		self.window.attroff(A_BOLD)
		self.window.addstr("[")
		self.window.attron(A_BOLD)
		self.window.addstr("L")
		self.window.attroff(A_BOLD)
		self.window.addstr("]oad Game")
		
		x = GuiHelper.center_x_for(self.window, "[T]ips")
		self.window.setpos(10, x)
		self.window.attroff(A_BOLD)
		self.window.addstr("[")
		self.window.attron(A_BOLD)
		self.window.addstr("T")
		self.window.attroff(A_BOLD)
		self.window.addstr("]ips")
		
		x = GuiHelper.center_x_for(self.window, "[Q]uit")
		self.window.setpos(11, x)
		self.window.attroff(A_BOLD)
		self.window.addstr("[")
		self.window.attron(A_BOLD)
		self.window.addstr("Q")
		self.window.attroff(A_BOLD)
		self.window.addstr("]uit")
		
		self.window.refresh
	end
	
	def show_name_inquiry
		self.window.clear
		draw_full_border
		self.window.setpos(3, 7)
		self.window.addstr("Enter your name, young adventurer: ");
		self.window.refresh
	end
	
	def show_save_games
		self.window.clear
		draw_full_border
		
		games = LoaderSaver.get_games
		if games.length == 0
			self.window.setpos(2, 2)
			self.window.addstr("There are no saved games.")
		else
			y = 3
			self.window.setpos(2, 2)
			self.window.addstr("Games:")
			
			i = 0
			
			games.each do |g|
				self.window.setpos(y, 4)
				self.window.addstr("[#{i}]: #{g}")
				y += 1
				i += 1
			end
		end
		
		self.window.refresh
	end
	
	def show_inventory(show_cost = false)
		self.window.clear
		draw_border
		
		y = 0
		
		self.window.setpos(2, 2)
		self.window.addstr("Inventory:");
		self.window.addstr(" (E to equip, L to load ammo)") if show_cost == false
		
		# sort list by type, then by damage/toughness, then alphabetically
		Player.instance.inventory.reassign_keys_and_sort
		
		last_class = Player.instance.inventory.contents[0].class
		
		Player.instance.inventory.contents.each do |i|
			y += 1 if i.class == Item && last_class != Item
			
			self.window.setpos(3 + y, 4) #3 = after "Inventory"
			self.window.addstr("[")
			self.window.color_set(COLOR_CYAN)
			self.window.addstr(i.key.to_s);
			self.window.color_set(COLOR_WHITE)
			self.window.addstr("] ")
			
			if (i.is_a?(RangeWeapon) && i == Player.instance.range_weapon) || (i.is_a?(Weapon) && i == Player.instance.weapon) || (i.is_a?(Armour) && i == Player.instance.armour[i.subtype])
				self.window.addstr("{")
				
				self.window.color_set(COLOR_RED) if i.is_a?(Weapon) || i.is_a?(RangeWeapon) || i.is_a?(Ammo)
				self.window.color_set(COLOR_YELLOW) if i.is_a?(Armour)
				
				self.window.addstr("E")
				self.window.color_set(COLOR_WHITE)
				self.window.addstr("} ")
			elsif (!Player.instance.range_weapon.nil? && i.is_a?(Ammo) && Player.instance.range_weapon.ammo == i)
				self.window.addstr("{")
				self.window.color_set(COLOR_RED)
				self.window.addstr("L")
				self.window.color_set(COLOR_WHITE)
				self.window.addstr("} ")
			end
			
			string = "#{i.quantity}x #{i.name}"
			
			if (i.identified == true)
				if i.is_a?(RangeWeapon)
					string += " (#{i.range}r)"
				elsif i.is_a?(Weapon)
					string += " (+#{i.damage})"
				elsif i.is_a?(Armour)
					string += " (+#{i.defense})"
				end
			end			
			
			if show_cost == true && (i.is_a?(RangeWeapon) || i.is_a?(Weapon) || i.is_a?(Armour))
				i.recalculate_cost
				string += " #{i.effective_cost} gold"
			end
			
			
			self.window.addstr(string)
			y += 1;
			last_class = i.class
			
		end
		
		self.window.refresh
	end
	
	def show_quest(quest)
		self.window.clear
		draw_border
		
		y = 0
		
		self.window.setpos(2, 2)
		GuiHelper.show_padded_message(self.window, quest.description);
		self.window.refresh
	end
	
	def show_quest_completion(quest)
		self.window.clear
		draw_border
		y = 0
		gold = quest.level * 1000
		self.window.setpos(2, 2)
		
		if (quest.name != "Execute Aarij")
			GuiHelper.show_padded_message(self.window, "Ah, you've slain #{quest.name}! Great! Here's #{gold} gold from our reserves!")
		else
			GuiHelper.show_padded_message(self.window, "You've defeated him? Aarij is dead? Ah ... Then it's over ... at last. Eh, what's this? You say you have a tome from him? Let me have that ...... by God ... You must let me read this. This ... this cannot be ...")
		end
		
		self.window.refresh
	end
	
	def show_quests
		self.window.clear
		draw_border
		
		y = 0
		
		self.window.setpos(2, 2)
		self.window.addstr("Quests:");
		
		# sort list alphabetically
		Player.instance.quests.each do |q|
			self.window.setpos(3 + y, 4) #3 = after title
			self.window.addstr("[#{q.is_complete == true ? 'Done' : 'Open'}] #{q.name}: #{q.summary}")
			y += 2;
		end
		
		self.window.refresh
	end
	
	def show_perks
		self.window.clear
		draw_border
		
		y = 0
		
		self.window.setpos(2, 2)
		self.window.addstr("Perks:");
		
		# sort list alphabetically
		Player.instance.perks.each do |p|
			self.window.setpos(3 + y, 4) #3 = after title
			self.window.addstr("#{p.name}: #{p.description}")
			y += 2;
		end
		
		self.window.refresh
	end
	
	def show_weapon_skills
		self.window.clear
		draw_border
		
		y = 0
		
		self.window.setpos(2, 2)
		self.window.addstr("Weapon Skills:");
		
		# sort list alphabetically
		Player.instance.weapon_skills.each do |s|
			self.window.setpos(3 + y, 4) #3 = after title
			points = s.points
			if (points > 0)
				self.window.attron(A_BOLD)
			else
				self.window.attroff(A_BOLD)
			end
			points = "0#{s.points}" if points < 10			
			
			if s.subtype == Player.instance.weapon.subtype
				self.window.color_set(COLOR_CYAN) 
			else
				self.window.color_set(COLOR_WHITE) 
			end
			
			self.window.addstr("#{s.subtype} #{s.level}:#{points}")
			y += 1;
		end
		
		y = 0
		Player.instance.range_weapon_skills.each do |s|
			self.window.setpos(3 + y, 30) #3 = after title
			points = s.points
			if (points > 0)
				self.window.attron(A_BOLD)
			else
				self.window.attroff(A_BOLD)
			end
			if !Player.instance.range_weapon.nil? && s.subtype == Player.instance.range_weapon.subtype
				self.window.color_set(COLOR_CYAN) 
			else
				self.window.color_set(COLOR_WHITE) 
			end
			
			points = "0#{s.points}" if points < 10
			self.window.addstr("#{s.subtype} #{s.level}:#{points}")
			y += 1;
		end
		
		self.window.refresh
	end
	
	def show_skills_experience
		self.window.clear
		draw_border
		
		y = 0
		
		self.window.setpos(2, 2)
		self.window.addstr("Skills:");
		
		# sort list alphabetically
		Player.instance.skills.each do |s|
			self.window.setpos(3 + y, 4) #3 = after title
			points = s.points
			points = "0#{s.points}" if points < 10
			self.window.addstr("#{s.name} #{s.level}:#{points} / #{s.real_cost}sp")
			y += 1;
		end
		
		self.window.refresh
	end
	
	def show_skills
		self.window.clear
		draw_border
		
		y = 0
		
		self.window.setpos(2, 2)
		self.window.addstr("Skills:");
		
		# sort list alphabetically
		Player.instance.skills.sort {|a,b| a.name <=> b.name }.each do |s|
			self.window.setpos(3 + y, 4) #3 = after "Skills"
			
			cost = s.real_cost
			raw = s.cost
			
			if raw.is_a?(String)
				cost = "#{cost} (#{raw}"
				if s.level > 0
					cost = "#{cost} - #{s.level}"
				end
				
				cost = "#{cost})"
			end
			
			self.window.addstr("[#{s.key}] #{s.name} - #{cost}: #{s.description}")
			
			y += 1;
		end
		
		StatusBar.instance.ask_which_skill
		self.window.refresh
	end
	
	def show_help
		self.window.clear
		draw_border
		self.window.setpos(2, 2)
		self.window.addstr("Commands:")
		y = 3
		
		write_menu_item("Arrow keys: move up/down/left/right. Collide to interact", y + 1);
		write_menu_item("[~] Console log", y + 2);
		write_menu_item("[c]haracter stats", y + 3);
		write_menu_item("[C]lose door", y + 4)
		write_menu_item("[d]rop item", y + 5)
		write_menu_item("[e]nter vortex", y + 6)
		write_menu_item("[f]ire range weapon", y + 7)
		write_menu_item("[g]et item on the floor", y + 8);
		write_menu_item("[i]nventory", y + 9);
		write_menu_item("[r] Rest until skill-points are at 100%", y + 10);
		write_menu_item("[s] use skill", y + 11);		
		write_menu_item("[S]ave game (town only)", y + 12);
		
		write_menu_item("[<] ascend stairs", y + 14);
		write_menu_item("[>] descend stairs", y + 15);
		write_menu_item("[.] pass time", y + 16);
		
		y += 1
		
		#self.window.setpos(y, 4)
		#self.window.addstr("[R] Full Rest. Rest until health and SP are 100%");
		y += 1
		
		#self.window.setpos(y, 4)
		#self.window.addstr("[space/period] Wait.");
		
		self.window.refresh
	end
	
	def show_tips
		self.window.clear
		draw_full_border
		
		self.window.attron(A_BOLD)
		self.window.setpos(2, 2)
		self.window.addstr("Tips:")
		self.window.attroff(A_BOLD)
		
		self.window.setpos(4, 3)
		self.window.addstr("1) It's a tough game. Keep trying.")
		self.window.setpos(5, 3)
		self.window.addstr("2) PlainRL is difficult. Achieve small victories.")
		self.window.setpos(6, 3)
		self.window.addstr("3) Build up your armour. It helps, especially later.")
		self.window.setpos(7, 3)
		self.window.addstr("4) Sacrifice for a ranged weapon.")
		self.window.setpos(8, 3)
		self.window.addstr("5) Don't leave 8F until you find the surprise.")
		self.window.setpos(9, 3)
		self.window.addstr("6) Use skills often. They improve with usage.")
		self.window.setpos(10, 3)
		self.window.addstr("7) You can equip different types of armour together.")
		
		
		self.window.setpos(12, 3)
		self.window.color_set(COLOR_YELLOW)
		self.window.addstr("8) Stuck? Try haste. It's strong stuff.")
		self.window.setpos(13, 3)
		self.window.addstr("9) Stuck? Improve Whirlwind; it's essential.")
		self.window.setpos(14, 3)
		self.window.addstr("10) Stuck? Dive in, kill a monster or two, flee. Repeat.")
		self.window.setpos(16, 3)
		self.window.color_set(COLOR_GREEN)
		self.window.addstr("11) The Queen gets stronger as you get stronger.")
		self.window.setpos(17, 3)
		self.window.addstr("12) Hatchings don't get stronger; try levelling up.")
		
		self.window.attroff(A_BOLD)
		self.window.color_set(COLOR_WHITE)
		self.window.refresh
	end
	
	
	private
	
	def write_menu_item(message, y, x_offset = 0)
		self.window.setpos(y, 4 + x_offset)
		self.window.addstr(message)
	end
	
	def write_submenu_item(message, y)
		self.window.setpos(y, 6)
		self.window.addstr(message)
	end
	

	def blacken_square(i)
		self.window.setpos(i, 0)
		self.window.addstr(" " * Globals.map_screen_width)
		self.window.setpos(Globals.map_screen_height - i, 0)
		self.window.addstr(" " * Globals.map_screen_width)
		self.window.refresh
	end
	
	def draw_border
		draw_full_border
	end
	
	def draw_full_border
		self.window.box(0, 0)
	end
	
	def is_in_range(o, start_x, start_y)
		end_x = start_x + Globals.map_screen_width
		end_y = start_y + Globals.map_screen_height
		
		if (o.x < start_x || o.x >= end_x || o.y < start_y || o.y >= end_y)
			return false
		else
			return true
		end
	end
	
	def start_x
		return [Player.instance.x - (Globals.screen_width / 2), 0].max
	end
	
	def start_y
		return [Player.instance.y - (Globals.screen_height / 2), 0].max
	end
end
