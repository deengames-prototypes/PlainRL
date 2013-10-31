#Townsperson
class Person < Being

	require "classes/entities/Armour"

	attr_accessor :interaction_code, :colour, :name # name is to identify quest owners
	
	@@trader_items = []
	@@farrier_items = []
	
	def self.trader_items
		@@trader_items
	end
	
	def self.trader_items=(value)
		@@trader_items = value
	end
	
	def self.farrier_items
		@@farrier_items
	end
	
	def self.farrier_items=(value)
		@@farrier_items = value
	end

	def self.symbol
		return "@"
	end
	
	def initialize(x, y, name, interaction_code, colour)
		self.x = x
		self.y = y
		self.name = name
		self.interaction_code = interaction_code
		self.colour = colour
	end
	
	def interact
		eval self.interaction_code
	end
	
	def self.heal_player
		Player.instance.current_health = Player.instance.total_health
		Player.instance.current_skill_points = Player.instance.total_skill_points
		StatusBar.instance.show_healer_talk
	end
	
	def self.talk_to_armour_maker

		items = []
		Player.instance.inventory.contents.each do |i|
			items << i if !i.is_a?(RangeWeapon) && !i.is_a?(Ammo) && !i.is_a?(Weapon) && !i.is_a?(Armour) && i.name != "Scrap Metal" && !i.name.include?("soul")
		end
		
		value = 0
		items.each do |i|
			value += i.quantity
		end
		
		item = item_for_value(value)
		if item == nil
			StatusBar.instance.show_message("Sorry, I don't have anything cheap enough for #{value} items.")
			return
		else
			mod = item.damage if item.is_a?(Ammo)
			mod = item.range if item.is_a?(RangeWeapon)
			mod = item.damage if item.is_a?(Weapon)
			mod = item.defense if item.is_a?(Armour)
			item.identified = true
			
			MainWindow.instance.show_inventory
			StatusBar.instance.show_message("For #{value} items, I'll give you a #{item.name} (+#{mod}). Deal? Y/N");
			key = InputHelper.read_char
		end
		
		if (key == Keys.LOWERCASE_Y)
			# sold!
			item.x = Player.instance.x + 1
			item.y = Player.instance.y
			
			deleted_value = 0
			goal_value = item.defense if item.is_a?(Armour)
			goal_value = item.damage if item.is_a?(Weapon)
			
			items.each do |i|
				if deleted_value < goal_value
					deleted_value += i.quantity
					Player.instance.inventory.contents.delete(i)
				end
			end
			
			Dungeon.instance.items << item
			StatusBar.instance.show_message("Deal!")
		else
			StatusBar.instance.show_message("Ok, up to you.")
		end
	end
	
	def self.item_for_value(value)
		Armour.armours.reverse.each do |a|
			if a.defense <= value
				return a
			end
		end
		
		return nil
	end
	
	def self.talk_to_trader
		# B to buy, S to sell
		MainWindow.instance.show_trader_menu
		key = InputHelper.read_char
		if key == Keys.LOWERCASE_B
			MainWindow.instance.show_trader_items
			which = InputHelper.read_line_and_show(MainWindow.instance.window)
			item = Person.trader_items[which.to_i - 1] # base 1 to base 0
			if item.nil?
				StatusBar.instance.show_message("Doesn't exist!")
			elsif Player.instance.gold < item.cost
				StatusBar.instance.show_message("I don't think you have that much gold ...")
			else
				Player.instance.gold -= item.cost
				item.x = Player.instance.x + 1
				item.y = Player.instance.y + 1
				Dungeon.instance.items << item
				StatusBar.instance.show_message("It's a deal!")
			end
		elsif key == Keys.LOWERCASE_S			
			StatusBar.instance.show_message("What would you like to sell? ")
			MainWindow.instance.show_inventory(true)
			
			while which != ""
				StatusBar.instance.show_message("What would you like to sell? ")
				which = InputHelper.read_line_and_show(StatusBar.instance.window)
				item = Player.instance.inventory.get_item_for_key(which)
				
				if !item.nil? && (item.is_a?(Ammo) || item.is_a?(RangeWeapon) || item.is_a?(Weapon) || item.is_a?(Armour)) && !item.name.include?("soul")
					
					Player.instance.inventory.remove(item)
					
					# unequip
					Player.instance.unequip_if_equipped(item) if item.quantity == 0
					StatusBar.instance.show_message("SOLD! Here's #{item.cost} gold. [more]")
					Player.instance.gold += item.cost
				else
					StatusBar.instance.show_message("Sorry, I'm not interested in that. [more]") if !item.nil?
					StatusBar.instance.show_message("Bye!") if item.nil?
				end
				InputHelper.read_char unless item.nil?
				MainWindow.instance.show_inventory(true)
			end
		end
	end
	
	def self.talk_to_farrier
		MainWindow.instance.show_farrier_items
		which = InputHelper.read_line_and_show(MainWindow.instance.window)
		
		item = Person.farrier_items[which.to_i - 1] # base 1 to base 0
		if item.nil?
			StatusBar.instance.show_message("Doesn't exist!")
		elsif Player.instance.gold < item.cost
			StatusBar.instance.show_message("You don't have that much gold!")
		else
			Player.instance.gold -= item.cost
			item.x = Player.instance.x + 1
			item.y = Player.instance.y + 1
			Dungeon.instance.items << item
			StatusBar.instance.show_message("Done deal!")
		end
	end
	
	def self.is_completed_now?(quest_name)
		return true if quest_name == "Trollus" && Player.instance.killed?(Monster.bosses["Trollus"])
		return true if quest_name == "Slime-X" && Player.instance.killed?(Monster.bosses["Slime-X"])
		return true if quest_name == "Decalotupus" && Player.instance.killed?(Monster.bosses["Decalotupus"])
		return true if quest_name.include?("Aarij") && Player.instance.killed?(Monster.bosses["Aarij the Mage"])
		return false
	end
	
	def self.talk_to_quest_maker
		
		if !Player.instance.has_any_quests?
			MainWindow.instance.show_game_backstory
		end
	
		give_player = nil
		
		# guaranteed sorted by level
		Quest.repository.each do |q|
			if !Player.instance.has_quest?(q.name)
				give_player = q
				break;
			elsif Player.instance.has_quest?(q.name) && Player.instance.get_quest(q.name).is_complete == false
				if (is_completed_now?(q.name))
					MainWindow.instance.show_quest_completion(q)
					Player.instance.gold += 1000 * q.level
					Player.instance.get_quest(q.name).is_complete = true
					InputHelper.read_char #wait
					return;
				else
					StatusBar.instance.show_message("I already have you a quest: #{q.name}!")
					return;
				end
			end
		end
		
		if !give_player.nil?
			Player.instance.quests << give_player
			MainWindow.instance.show_quest(give_player)
			InputHelper.read_char
		else
			# theoretically impossible; we always give a quest, even for end-of-game; that one never completes.
			StatusBar.instance.show_message("Sorry, I don't have any more quests!")
		end
	end
	
	def self.collect_keys
		char = InputHelper.read_char
		which = ""
		
		while (char != Keys.ENTER) do
			which += char.chr
			char = InputHelper.read_char
		end
		
		return which
	end
	
	def self.generate_trader_items
		
		weapons = []
		num_items = Globals.trader_items_for_sale / 2
		
		while num_items > 0
			weapon = Weapon.random_weapon(1, Weapon.weapons.length)
			weapon.identified = true
			
			dupe = false
			# include? equality = name, damage
			weapons.each do |w|
				if w.name == weapon.name && w.damage == weapon.damage
					dupe = true
				end
			end
			
			if !dupe
				weapons << weapon				
				num_items -= 1
			end
		end
		
		armours = []
		num_items = Globals.trader_items_for_sale / 2
		
		while num_items > 0
			armour = Armour.random_armour
			armour.identified = true
			
			dupe = false
			# include? equality = name, damage
			armours.each do |a|
				if a.name == armour.name && a.defense == armour.defense
					dupe = true
				end
			end
			
			if !dupe
				armours << armour				
				num_items -= 1
			end
		end
		
		weapons = weapons.sort_by {|x| [x.class, x.damage, x.name]}
		armours = armours.sort_by {|x| [x.class, x.defense, x.name]}
		
		@@trader_items = weapons + armours
	end
	
	def self.generate_farrier_items
		
		range_weapons = []
		num_items = 5
		
		while num_items > 0
			weapon = RangeWeapon.random_range_weapon(1, RangeWeapon.range_weapons.length)
			weapon.identified = true
			
			dupe = false
			# include? equality = name, damage
			range_weapons.each do |w|
				if w.name == weapon.name && w.range == weapon.range
					dupe = true
				end
			end
			
			if !dupe
				range_weapons << weapon				
				num_items -= 1
			end
		end
		
		ammo_items = []
		num_items = 5
		
		while num_items > 0
			ammo = Ammo.random_ammo()
			ammo.identified = true
			ammo.quantity = Globals.farrier_items_ammo_quantity
			
			dupe = false
			# include? equality = name, damage
			ammo_items.each do |a|
				if a.name == ammo.name && a.damage == ammo.damage
					dupe = true
				end
			end
			
			if !dupe
				ammo_items << ammo
				num_items -= 1
			end
		end
		
		ammo_items << Ammo.new("wooden arrow", "arrow", 5, "|", 100, true)
		ammo_items << Ammo.new("wooden bolt", "bolt", 5, "|", 100, true)
		
		range_weapons = range_weapons.sort_by {|x| [x.class, x.range, x.name]}
		ammo_items = ammo_items.sort_by {|x| [x.class, x.damage, x.name]}
		
		@@farrier_items = range_weapons + ammo_items
	end
	
	def self.rescue_blacksmith
		StatusBar.instance.show_message("Blacksmith: Thanks for rescuing me! I found my hammer at last! See you in town!")
		Game.instance.set_global("rescued_blacksmith", true)
	end
	
	def self.talk_to_blacksmith
		# B to buy, S to sell
		MainWindow.instance.show_blacksmith_menu
		key = InputHelper.read_char
		
		if key == Keys.LOWERCASE_F
			# FORGE! Pick two items: A, B, and metal
			
			forge_level = [(Game.instance.get_global("num_items_fused") / Globals.points_per_forge_level) + 1, Globals.max_forge_level].min			
			
			if !Player.instance.inventory.has_item?("Scrap Metal")
				StatusBar.instance.show_message("You need scrap metal first before you can forge anything!")
				return
			end
			
			MainWindow.instance.show_inventory
			StatusBar.instance.show_message("Pick two weapons or armour, and I'll fuse 'em together using scrap metal! The first: ");
			which = InputHelper.read_line_and_show(StatusBar.instance.window)
			item1 = Player.instance.inventory.get_item_for_key(which)
			if (!item1.is_a?(Weapon) && !item1.is_a?(Armour))
				StatusBar.instance.show_message("I only take weapons and armour.")
				return
			end
			StatusBar.instance.show_message("Item 1: #{item1.name} (#{item1.subtype}) And the second: ")
			
			which = InputHelper.read_line_and_show(StatusBar.instance.window)
			item2 = Player.instance.inventory.get_item_for_key(which)
			if (!item2.is_a?(Weapon) && !item2.is_a?(Armour))
				StatusBar.instance.show_message("I only take weapons and armour.")
				return
			end
			
			if (item1 == item2)
				StatusBar.instance.show_message("Pick two DIFFERENT items!")
			#elsif (item1.class != item2.class)
			#	StatusBar.instance.show_message("You need to pick two weapons or two armour!")
			else
				base_damage = [item1.modifier, item2.modifier].max
				addition = [item1.modifier, item2.modifier].min
				
				addition = (0.1 * forge_level * addition).to_i
				
				cost = (item1.scrap_metal + item2.scrap_metal) / 4
				
				if !Player.instance.inventory.has_n_of_item?("Scrap Metal", cost)
					StatusBar.instance.show_message("You don't have #{cost} scrap metal!")
					return
				end
				
				x = Player.instance.x + 1
				y = Player.instance.y
				
				if !Dungeon.instance.is_clear?(x, y)
					x = Player.instance.x - 1
					if !Dungeon.instance.is_clear?(x, y)
						x = Player.instance.x
						y = Player.instance.y - 1
						if !Dungeon.instance.is_clear?(x, y)
							y = Player.instance.y + 1
							if !Dungeon.instance.is_clear?(x, y)
								raise "Can't find empty X, Y adjacent to player."
							end
						end
					end
				end
				
				if (item1.subtype != item2.subtype)
					StatusBar.instance.show_message("I can make a(n) #{item1.subtype} or #{item2.subtype} of +#{base_damage + addition} with #{cost} scrap metal; is that OK? Press 1 for #{item1.subtype}, or 2 for #{item2.subtype}.")
					
					which = InputHelper.read_char
					if (which == Keys.ONE)
					
						if !Player.instance.inventory.has_n_of_item?("Scrap Metal", cost)
							StatusBar.instance.show_message("You don't have #{cost} scrap metal!")
							return
						end
					
						Player.instance.inventory.remove(item1)
						Player.instance.inventory.remove(item2)
						Player.instance.inventory.remove("Scrap Metal", cost)
						
						if (item1.is_a?(Weapon))
							forged = Weapon.new(item1.name, item1.subtype, base_damage + addition, item1.symbol, 1, true)
						elsif item1.is_a?(Armour)
							forged = Armour.new(item1.name, item1.subtype, base_damage + addition, item1.symbol, 1, true)
						#else # bow
						#	forged = RangeWeapon.new(item1.name, item1.subtype, base_damage + addition, item1.symbol, 1, true)
						end
						
						forged.x = x
						forged.y = y
						Dungeon.instance.items << forged
						increment_forged_points
						
					elsif (which == Keys.TWO)
					
						if !Player.instance.inventory.has_n_of_item?("Scrap Metal", cost)
							StatusBar.instance.show_message("You don't have #{cost} scrap metal!")
							return
						end
					
						Player.instance.inventory.remove(item1)
						Player.instance.inventory.remove(item2)
						Player.instance.inventory.remove("Scrap Metal", cost)
						
						if (item1.is_a?(Weapon))
							forged = Weapon.new(item2.name, item2.subtype, base_damage + addition, item2.symbol, 1, true)
						elsif item1.is_a?(Armour)
							forged = Armour.new(item2.name, item2.subtype, base_damage + addition, item2.symbol, 1, true)
						#else # bow
						#	forged = RangeWeapon.new(item2.name, item2.subtype, base_damage + addition, item2.symbol, 1, true)
						end
						
						forged.x = x
						forged.y = y
						Dungeon.instance.items << forged
						increment_forged_points
						
					else
						StatusBar.instance.show_message("OK, come back anytime if you change yer mind.")
					end
				else
					StatusBar.instance.show_message("I can make a(n) #{item1.subtype} of +#{base_damage + addition} with #{cost} scrap metal; is that OK? Y/N")
					which = InputHelper.read_char
					if (which == Keys.LOWERCASE_Y)
						
						if !Player.instance.inventory.has_n_of_item?("Scrap Metal", cost)
							StatusBar.instance.show_message("You don't have #{cost} scrap metal!")
							return
						end
						
						Player.instance.inventory.remove(item1)
						Player.instance.inventory.remove(item2)
						Player.instance.inventory.remove("Scrap Metal", cost)
						
						# do it!!
						if (item1.is_a?(Weapon))
							forged = Weapon.new(item1.name, item1.subtype, base_damage + addition, item1.symbol, 1, true)
						elsif item1.is_a?(Armour)
							forged = Armour.new(item1.name, item1.subtype, base_damage + addition, item1.symbol, 1, true)
						#elsif item1.is_a?(RangeWeapon)
						#	forged = RangeWeapon.new(item1.name, item1.subtype, base_damage + addition, item1.symbol, 1, true)
						end
						
						forged.x = x
						forged.y = y
						Dungeon.instance.items << forged
						increment_forged_points
						
					else
						StatusBar.instance.show_message("OK, come back anytime if you change yer mind.")
					end
				end
			end
		elsif key == Keys.LOWERCASE_D
			# DISMANTLE! Pick the item
			MainWindow.instance.show_inventory
			StatusBar.instance.show_message("Which item? ")
			
			which = InputHelper.read_line_and_show(StatusBar.instance.window)
			item = Player.instance.inventory.get_item_for_key(which)
			
			if !item.nil? && (item.is_a?(Weapon) || item.is_a?(Armour))
				Player.instance.inventory.remove(item)
				num_scrap = item.scrap_metal
				num_scrap = 1 if num_scrap == 0
				StatusBar.instance.show_message("Ergh! DONE! Here's the scrap!")
				Game.instance.set_global("num_items_fused", Game.instance.get_global("num_items_fused") + 1)
				
				y = Player.instance.y
				if Dungeon.instance.is_clear?(Player.instance.x - 1, Player.instance.y)
					x = Player.instance.x - 1
				elsif Dungeon.instance.is_clear?(Player.instance.x + 1, Player.instance.y)
					x = Player.instance.x + 1
				end
				
				scrap =  Item.new("Scrap Metal", "*", num_scrap)
				scrap.x = x
				scrap.y = y
				
				Dungeon.instance.items << scrap
			else
				StatusBar.instance.show_message("Can't do anything with that!")
			end
		end
	end
	
	private
	
	def self.increment_forged_points
		Game.instance.set_global("num_items_fused", Game.instance.get_global("num_items_fused") + 1)
	end
end