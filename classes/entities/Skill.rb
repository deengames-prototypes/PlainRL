class Skill
	require "classes/entities/Vortex"
	
	attr_accessor :cost, :name, :description, :key, :logic, :total_points
	
	@@repository = []
	@@using_whirlwind = false
	
	def self.using_whirlwind
		@@using_whirlwind
	end
	
	def self.using_whirlwind=(value)
		@@using_whirlwind = value
	end
	
	def self.repository
		@@repository
	end
	
	def initialize(name, description, cost, key, logic)
		self.name = name
		self.description = description
		self.cost = cost
		self.key = key
		self.logic = logic
		self.total_points = 0
	end
	
	def do_logic
		eval self.logic
	end	
	
	def self.try_to_use(key)
		Player.instance.skills.each do |s|
			if s.key.to_s.upcase == key.chr.upcase
				if Player.instance.current_skill_points >= s.real_cost
					
					MainWindow.instance.draw
					if s.do_logic() == true
						s.total_points += 1
						if s.total_points % Globals.points_per_skill_level == 0
							StatusBar.instance.show_message("#{s.name} increased to level #{s.level}. [more]")
							InputHelper.read_char
						end
					end
					
					Player.instance.current_skill_points -= s.real_cost
					StatusBar.instance.show_used_skill(s.name)
					SideWindow.instance.show_player_health
					
				else
					StatusBar.instance.show_not_enough_skill_points
				end
			end
		end
	end
	
	def points
		return self.total_points % Globals.points_per_skill_level
	end
	
	def level
		return self.total_points / Globals.points_per_skill_level
	end
	
	def real_cost
		real_cost = self.cost
		if !real_cost.is_a?(Numeric)
			percent = self.cost[0 .. -2].to_i # trim the %, multiply
			real_cost = (Player.instance.total_skill_points * percent) / 100
		else
			real_cost = real_cost.to_i
		end
		
		# real cost is now an int
		real_cost -= self.level
		real_cost = 1 if real_cost < 1
		
		return real_cost
	end
	
	############## skill logic #####################
	
	def self.whirlwind
		Skill.using_whirlwind = true # show all stars at once
		to_return = false
		s = Player.instance.find_skill("whirlwind")
		d = Dungeon.instance
		p = Player.instance
		range = s.level + 1
		additive = p.strength * (s.level + 2)
		p.strength += additive
		
		hit = []
		
		# all eight directions
		d.monsters.to_array.each do |m|
			if Math.sqrt(((m.x - p.x)**2) + ((m.y - p.y)**2)) <= range && Dungeon.instance.is_in_line_of_sight?(p.x, p.y, m.x, m.y) && m.is_alive?
				hit << m
				p.attack(m) 
				to_return = true
			end
		end
		
		p.strength -= additive
		MainWindow.instance.show_hurt_stars(hit)
		Skill.using_whirlwind = false
		return to_return
	end
	
	def self.ruqiyyah
		s = Player.instance.find_skill("ruqiyyah")
		old_health = Player.instance.current_health
		heal_percent = (s.level + 1) * 10 / 100.00
		Player.instance.current_health += (heal_percent * Player.instance.total_health).to_i
		Player.instance.current_health = Player.instance.total_health if Player.instance.current_health > Player.instance.total_health
		return Player.instance.current_health > old_health
	end
	
	def self.identify_item
		MainWindow.instance.show_inventory
		
		which = ""
		char = InputHelper.read_char
		
		while (char != Keys.ENTER) do
			which += char.chr
			char = InputHelper.read_char
		end
		
		to_identify = Player.instance.inventory.get_item_for_key(which)
		to_return = true unless to_identify.nil? || to_identify.identified == true

		to_identify.identify unless to_identify.nil?
		return to_return
	end
	
	def self.impale
		StatusBar.instance.ask_which_direction
		key = InputHelper.read_char
		return Player.instance.impale(key, Player.instance.find_skill("impale").level);
	end
	
	def self.stab
		StatusBar.instance.ask_which_stab_direction
		key = InputHelper.read_char
		return Player.instance.stab(key, Player.instance.find_skill("stab").level);
	end
	
	def self.hasten
		old_additive = Player.instance.agility_additive
		Player.instance.agility_additive = Player.instance.agility
		return old_additive != Player.instance.agility_additive
	end	
	
	def self.create_vortex
		return false if Dungeon.instance.floor_num == 0
		point = Dungeon.instance.generate_adjacent_clear_x_y(Player.instance.x, Player.instance.y)
		if !point.nil?
			x = point.x 
			y = point.y 
			Dungeon.instance.vortex = Vortex.new(x, y)
			Player.instance.vortex_floor = Dungeon.instance.floor_num
			return true
		else
			return false
		end
	end
end
