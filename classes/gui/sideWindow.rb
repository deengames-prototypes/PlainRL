class SideWindow

	require "ncurses"
	
	require "Singleton"
	include Singleton
	
	require "classes/Globals"
	require "classes/gui/MockWindow"
	require "classes/gui/Window"
	
	attr_accessor :window
	
	def initialize
		if Globals.testing == false
			self.window = Window.new(Globals.side_window_width, Globals.side_window_height, Globals.map_screen_width, 0)
		else
			self.window = MockWindow.new
		end
	end
		
	def show_monster_health(monster)
		return if !monster.is_alive?
		self.window.setpos(8, 2)
		self.window.addstr("#{monster.name}:")
		self.window.setpos(9, 2)
		self.window.addstr("#{monster.current_health}/#{monster.total_health}")
		self.window.refresh
	end
	
	def draw
		self.window.clear
		self.show_player_health
		self.draw_border
		self.show_floor
		self.window.refresh
	end

	def show_player_health
		self.window.color_set(COLOR_WHITE)
		self.window.attron(A_BOLD)
		self.window.setpos(2, 2)
		self.window.color_set(COLOR_YELLOW)
		self.window.addstr("Health:")
		self.window.setpos(3, 2)
		self.window.addstr(" " * 12)
		self.window.setpos(3, 2)
		self.window.color_set(COLOR_WHITE)
		self.window.addstr("#{Player.instance.current_health}/#{Player.instance.total_health}")
		self.window.setpos(5, 2)
		self.window.color_set(COLOR_CYAN)
		self.window.addstr("Skill Points:")
		self.window.color_set(COLOR_WHITE)
		self.window.setpos(6, 2)
		self.window.addstr(" " * 12)
		self.window.setpos(6, 2)
		self.window.addstr("#{Player.instance.current_skill_points.to_i}/#{Player.instance.total_skill_points}")
		self.show_monster_count
		self.window.attroff(A_BOLD)
		self.window.refresh
	end
	
	def close
		self.window.close unless window.nil?
	end
	
	def draw_border
		self.window.box(0, 0)		
		self.show_floor
	end
	
	def show_floor
		self.window.color_set(COLOR_WHITE)
		self.window.attroff(A_BOLD)
		self.window.setpos(0, (Globals.side_window_width - 4)/ 2)
		self.window.setpos(0, (Globals.side_window_width - 4)/ 2)
		self.window.addstr("[")
		
		self.window.attron(A_BOLD)
		if Dungeon.instance.floor_num > 0
			self.window.color_set(COLOR_YELLOW) if  Dungeon.instance.floor_num < 30
			self.window.color_set(COLOR_RED) if  Dungeon.instance.floor_num == 30
			self.window.addstr("#{Dungeon.instance.floor_num}F")
		else
			self.window.color_set(COLOR_CYAN)
			self.window.addstr("Town")
		end
		self.window.attroff(A_BOLD)
		self.window.color_set(COLOR_WHITE)
		
		self.window.addstr("]")
		self.window.refresh
	end
	
	def show_levelup(times, hp, sp, str, agi, tough)
		y = 11
		self.window.setpos(y, 2)
		self.window.addstr("Gained #{times} level(s)!")
		self.window.setpos(y + 1, 2)
		self.window.addstr("Health +#{hp}")
		self.window.setpos(y + 2, 2)
		self.window.addstr("Skill +#{sp}")
		self.window.setpos(y + 3, 2)
		self.window.addstr("STR +#{str}")
		self.window.setpos(y + 4, 2)
		self.window.addstr("TGH +#{tough}")
		self.window.setpos(y + 5, 2)
		self.window.addstr("AGI +#{agi}")
		self.window.setpos(y + 7, 2)
		self.window.addstr("[more]")
		self.window.refresh
		InputHelper.read_char
		
		self.window.clear
		self.draw_border
		self.show_monster_count
		self.window.refresh
	end
	
	def show_trader_item(value)
		i = Person.item_for_value(value)
		self.window.setpos(7, 2)
		self.window.addstr("                                   ");
		
		if i.nil?
			name = "nothing"
		else
			name = i.name
		end
		
		self.window.setpos(7, 2)
		self.window.addstr("So far: #{name}")
		self.window.refresh
	end
	
	def show_monster_count
		 if Player.instance.has_perk?("Monster Sense") && Dungeon.instance.floor_num > 0
			self.window.setpos(22, 2)
			self.window.addstr("Monsters:     ") # clear old text; fixes bug where count is 10, then 90, 80, ...
			self.window.setpos(22, 2)
			self.window.addstr("Monsters: #{Dungeon.instance.monsters.length}")
		end
	end
end