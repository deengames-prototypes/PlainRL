require "ncurses"

require "classes/entities/Dungeon"
require "classes/utils/InputHelper"
require "classes/utils/Keys"
require "classes/utils/Hooks"
require "classes/gui/SideWindow"
require "classes/gui/MainWindow"
require "classes/utils/DataMaster"
require "classes/utils/Profiler"


def setup_new_game
	DataMaster.assign_new_game_data
	
	# generates town
	Dungeon.instance.floor_num = 1
	Dungeon.instance.generate_previous_floor
	
	Player.instance.x = Dungeon.instance.width / 2
	Player.instance.y = Dungeon.instance.height - 2
	
	Game.instance.set_global("num_saves", 0)
	Game.instance.set_global("endgame", false)
	
	MainWindow.instance.draw
	SideWindow.instance.draw

	StatusBar.instance.show_new_game_dialog
end

def do_game_logic(refresh = true)
	player = Player.instance
	dungeon = Dungeon.instance
	
	if Dungeon.instance.is_item?(player.x, player.y)
		StatusBar.instance.show_on_item(Dungeon.instance.item_at(player.x, player.y))
	elsif Dungeon.instance.is_vortex_at?(player.x, player.y)
		StatusBar.instance.show_message("You see a swirling vortex of energy. (E to enter)")
	end

	dungeon.monsters.to_array.each do |m|
		m.move if m.is_alive?
	end
	
	if dungeon.floor_num == 8 && Game.instance.get_global("rescued_blacksmith") == false && rand(100) == 99
		StatusBar.instance.show_message("Someone shouts for help. [more]") 
		InputHelper.read_char
	end

	if (player.current_health <= 0)
		MainWindow.instance.show_game_over
	end
end

def do_main_menu
	MainWindow.instance.show_main_menu
	key = InputHelper.read_char
	
	while (key != Keys.LOWERCASE_N && key != Keys.LOWERCASE_L && key != Keys.LOWERCASE_T && key != Keys.LOWERCASE_Q)
		key = InputHelper.read_char
	end
	
	if key == Keys.LOWERCASE_N
		MainWindow.instance.show_name_inquiry
		Player.instance.name  = InputHelper.read_line_and_show(MainWindow.instance.window)
		
		MainWindow.instance.window.setpos(5, 7)
		MainWindow.instance.window.addstr("Generating world ...")
		MainWindow.instance.window.refresh
		
		DataMaster.populate_repositories
		setup_new_game
	elsif key == Keys.LOWERCASE_T
		MainWindow.instance.show_tips
		key = InputHelper.read_char
		do_main_menu
	elsif key == Keys.LOWERCASE_L
		MainWindow.instance.show_save_games
		StatusBar.instance.show_message("Which game? ")
		keys = nil
		loaded = false
		
		while !LoaderSaver.game_exists?(keys) && keys != ""
			
			keys = InputHelper.read_line_and_show(StatusBar.instance.window)
			if LoaderSaver.game_exists?(keys)
				StatusBar.instance.show_message("Generating world ...")
				LoaderSaver.load_game(keys)
				DataMaster.populate_repositories
				loaded = true
				Person.generate_trader_items
				Person.generate_farrier_items
			else
				StatusBar.instance.show_message("That game is not valid. Which game? ")
			end
		end
		
		if (loaded == false)
			do_main_menu
		end
	elsif key == Keys.LOWERCASE_Q
		# quit
		exit
	end
end

Hooks.add_startup("Logger.create")

Hooks.run_startup

Hooks.add_shutdown("SideWindow.instance.close")
Hooks.add_shutdown("StatusBar.instance.close")
Hooks.add_shutdown("MainWindow.instance.close")
Hooks.add_shutdown("Profiler.dump_log")

SCREEN_WIDTH = Globals.screen_width
SCREEN_HEIGHT = Globals.screen_height

do_main_menu

player = Player.instance
dungeon = Dungeon.instance
s = SideWindow.instance
key = ""

StatusBar.instance.draw
SideWindow.instance.draw
MainWindow.instance.draw

begin
	while player.is_alive? && key != Keys.CTRL_C && Game.instance.get_global("endgame") == false

		do_logic = true
		
		case(key)
			when Keys.UP			
				player.try_to_move(player.x, player.y - 1)
			when Keys.DOWN
				player.try_to_move(player.x, player.y + 1)
			when Keys.LEFT
				player.try_to_move(player.x - 1, player.y)
			when Keys.RIGHT
				player.try_to_move(player.x + 1, player.y)
			when Keys.TILDE
				MainWindow.instance.show_console_log
				do_logic = false
				key = InputHelper.read_char
			when Keys.ARROW_RIGHT
				if Dungeon.instance.is_stairs_down?(player.x, player.y)
					Dungeon.instance.generate_next_floor
					MainWindow.instance.draw
				else
					# no stairs to descend!
				end
			when Keys.ARROW_LEFT
				if Dungeon.instance.is_stairs_up?(player.x, player.y)
					Dungeon.instance.generate_previous_floor
					MainWindow.instance.draw
				else
					# no stairs to ascend!
				end
			when Keys.LOWERCASE_D
				MainWindow.instance.show_inventory
				StatusBar.instance.show_message("Drop which item?")
				which = InputHelper.read_line_and_show(StatusBar.instance.window)
				item = Player.instance.inventory.get_item_for_key(which)
				if !item.nil?
					Player.instance.inventory.remove_all(item)
					Player.instance.unequip_if_equipped(item)
					item.x = Player.instance.x
					item.y = Player.instance.y
					Dungeon.instance.items << item
				else
					StatusBar.instance.show_message("Nothing to drop!")
				end
			when Keys.LOWERCASE_F
				if Player.instance.range_weapon.nil?
					StatusBar.instance.show_message("You don't have a ranged weapon equipped!")
				elsif Player.instance.range_weapon.ammo.nil?
					StatusBar.instance.show_message("You're out of ammo!")
				else
					# logic: if we fired and hit someone, or tried and couldn't.
					do_logic = Player.instance.try_to_fire
				end
			when Keys.UPPERCASE_G, Keys.LOWERCASE_G, Keys.COMMA
				# checks if there's an item there
				Dungeon.instance.give_item_to_player
			when Keys.UPPERCASE_C
				StatusBar.instance.ask_which_direction_for_close_door
				key = InputHelper.read_char
				case(key)
					when Keys.UP
						Dungeon.instance.try_to_close_door(player.x, player.y - 1)
					when Keys.DOWN
						Dungeon.instance.try_to_close_door(player.x, player.y + 1)
					when Keys.LEFT
						Dungeon.instance.try_to_close_door(player.x - 1, player.y )
					when Keys.RIGHT
						Dungeon.instance.try_to_close_door(player.x + 1, player.y )
					else
						#invalid
				end
			when Keys.LOWERCASE_R
				# stop if hurt
				is_hurt = false
				
				while (player.current_skill_points < player.total_skill_points && is_hurt == false)
					player.increment_skill_points
					old_hp = player.current_health
					
					StatusBar.instance.is_suppressing_messages = true
					do_game_logic(false)
					StatusBar.instance.is_suppressing_messages = false
					
					if (player.current_health < old_hp)
						is_hurt = true
					end
				end
				
				SideWindow.instance.draw
				do_logic = false
			when Keys.LOWERCASE_I
				do_logic = false
				MainWindow.instance.show_inventory
				key = InputHelper.read_char
				if (key == Keys.LOWERCASE_E)
					StatusBar.instance.ask_equip_what
					which = InputHelper.read_line_and_show(StatusBar.instance.window)					
					Player.instance.equip_item_for_key(which.chomp)
				elsif (key == Keys.LOWERCASE_L)
					if Player.instance.range_weapon.nil?
						StatusBar.instance.show_message("You don't have a range weapon equipped!")
					else
						StatusBar.instance.show_message("Load which ammo?")
						which = InputHelper.read_line_and_show(StatusBar.instance.window)
						item = Player.instance.inventory.get_item_for_key(which)
						if !item.is_a?(Ammo)
							StatusBar.instance.show_message("You can only load ammo!")
						else
							if ((Player.instance.range_weapon.subtype == "bow" || Player.instance.range_weapon.subtype == "longbow") && item.subtype == "arrow") ||
								(Player.instance.range_weapon.subtype == "crossbow" && item.subtype == "bolt")
							
								Player.instance.range_weapon.ammo = item
								StatusBar.instance.show_message("Locked and loaded!")
							else
								StatusBar.instance.show_message("You can only equip arrows in bows, and bolts in crossbows.")
							end
						end
						
					end
				end
				MainWindow.instance.draw
			when Keys.LOWERCASE_S
				MainWindow.instance.show_skills
				key = InputHelper.read_char
				Skill.try_to_use(key)
			when Keys.UPPERCASE_S
				if Dungeon.instance.floor_num == 0
					LoaderSaver.save_data(Player.instance.name)
					StatusBar.instance.show_message("Saved.")
				else
					StatusBar.instance.show_message("You can only save in town.")
				end
				do_logic = false
			when Keys.LOWERCASE_C
				do_logic = false
				MainWindow.instance.show_character_status
				key = InputHelper.read_char
				
				if key == Keys.LOWERCASE_A
					Player.instance.auto_arrow_management = !Player.instance.auto_arrow_management
					if Player.instance.auto_arrow_management == true
						StatusBar.instance.show_message("Enabled. Arrows will be consumed automatically.")
					else
						StatusBar.instance.show_message("Disabled.")
					end
				elsif key == Keys.LOWERCASE_P
					MainWindow.instance.show_perks
				elsif key == Keys.LOWERCASE_Q
					MainWindow.instance.show_quests
				elsif key == Keys.LOWERCASE_S
					MainWindow.instance.show_skills_experience
				elsif key == Keys.LOWERCASE_W
					MainWindow.instance.show_weapon_skills
				end
				
				key = InputHelper.read_char
				MainWindow.instance.draw
			when Keys.LOWERCASE_E
				if Dungeon.instance.is_vortex_at?(Player.instance.x, Player.instance.y)
					if Dungeon.instance.floor_num == 0
						Dungeon.instance.floor_num = Player.instance.vortex_floor
						Dungeon.instance.generate
						Dungeon.instance.start_time = Time.new
						SideWindow.instance.show_floor
					else
						Dungeon.instance.floor_num = 0
						Dungeon.instance.generate_town
					end
					MainWindow.instance.draw
				end
			when Keys.SPACE, Keys.PERIOD
				# pass time
			when Keys.QUESTION_MARK
				do_logic = false
				MainWindow.instance.show_help
			else
				# ... unknown
				do_logic = false
				StatusBar.instance.show_message("Invalid key. Press ? for help.") unless key == ""
		end
		
		if do_logic && Game.instance.get_global("endgame") == false
			do_game_logic
		end
		
		# clear last turn LOS cache
		Dungeon.instance.clear_los_cache
		Player.instance.increment_skill_points
		
		# update display
		MainWindow.instance.draw unless Player.instance.current_health <= 0 || Game.instance.get_global("endgame") == true || do_logic == false
		
		key = InputHelper.read_char

		# remove old messages
		SideWindow.instance.draw
		StatusBar.instance.draw
	end
	
	if Game.instance.get_global("endgame") == true
		MainWindow.instance.show_endgame
	end

ensure
	Hooks.run_shutdown
	Ncurses::nocbreak();
end

