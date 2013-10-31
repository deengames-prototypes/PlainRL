class StatusBar
	require "ncurses"
	
	require "classes/gui/MockWindow"
	require "classes/gui/Window"
	
	require "Singleton"	
	include Singleton
	
	attr_accessor :window, :is_suppressing_messages, :messages
	
	def initialize
		if Globals.testing == false
			self.window = Window.new(Globals.status_bar_width, Globals.status_bar_height, 0, Globals.map_screen_height)
		else
			self.window = MockWindow.new
		end
		
		self.is_suppressing_messages = false
		
		self.messages = []
	end
	
	def show_new_game_dialog
		show_message("You leap through the gate as the boulder slams into it. Sealed. [more]")
		InputHelper.read_char
		show_message("The village shaykh (yellow) gapes at you. \"Are you ... an adventurer?\" [more]")
		InputHelper.read_char
		show_message("\"Our prayers have been answered! Our salvation, at last!\" Tears of relief streak down his face. [more]")
		InputHelper.read_char
	end
	
	def show_monster_death(monster, experience)
		self.show_message("#{monster.name} dies! Got #{experience} EXP!")
	end
	
	def ask_which_impale_direction
		ask_which_direction("Impale")
	end
	
	def ask_which_direction(keyword = "")				
		if keyword != ""
			show_message("#{keyword} in which direction?")
		else
			show_message("In which direction?")
		end
		
		self.window.refresh
	end
	
	def show_perk_gained(p)
		self.show_message("Gained #{p.name} perk: #{p.description} [more]");
		InputHelper.read_char
		SideWindow.instance.show_monster_count
	end
	
	def ask_which_stab_direction
		ask_which_direction("Stab")
	end
	
	def ask_which_skill
		show_message("Which skill do you want to use?")
	end
	
	def show_used_skill(name)
		show_message("You used #{name}!")
	end
	
	def show_not_enough_skill_points
		show_message("You don't have enough skill points for that!")
	end
	
	def show_player_attack_message(monster, damage)
		show_message("Player attacked #{monster.name} for #{damage} damage!")
		SideWindow.instance.show_monster_health(monster)
	end

	
	
	def show_message(message)
		return if is_suppressing_messages == true
		
		self.draw
		self.window.setpos(1, 2)
		GuiHelper.show_padded_message(self.window, message) if !message.nil? 
		
		while (@messages.length > 20)
			@messages.delete_at(0)
		end

		self.messages << message 
	
		self.window.refresh
	end
	
	def show_monster_attack_message(monster, damage)
		if !self.is_suppressing_messages
			show_message("#{monster.name} attacked player for #{damage} damage!")
			SideWindow.instance.show_player_health
		end
	end
	
	def show_healer_talk
		show_message("Healer: I will heal you, my brother ...")		
	end
	
	def ask_which_materials
		show_message("I make armour. I'll make you something. Got anything useful? (Type item numbers and press enter)")
	end
	
	def show_will_make_armour(item)		
		self.show_message("Here ye go! A nice, new #{item.name}!")
	end
	
	def draw
		self.window.clear	
		draw_border
		self.window.refresh
	end
	
	def draw_border
		self.window.box(0, 0)
	end
	
	def show_on_item(item)
		quantity = "a(n)" if item.quantity == 1
		quantity = item.quantity if item.quantity > 1
		name = item.name
		name += "s" if item.quantity > 1
		
		show_message("You see #{quantity} #{name} here.")
	end
	
	def show_get(item)
		quantity = "a(n)" if item.quantity == 1
		quantity = item.quantity if item.quantity > 1
		name = item.name
		name += "s" if item.quantity > 1
		
		show_message("You got #{quantity} #{name}.")
	end
	
	def ask_which_direction_for_close_door
		show_message("Close a door in which direction?")
	end
	
	def ask_equip_what
		show_message("Equip which item? (Type the number and press enter)");
	end
	
	def show_game_over
		show_message("You are DEAD! Press any key to quit.")
	end
	
	def close
		self.window.close unless window.nil?
	end
end