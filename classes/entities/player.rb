class Player < Being

	require "Singleton"
	include Singleton
	
	require "classes/entities/Being"
	require "classes/entities/Inventory"
	require "classes/entities/Weapon"
	require "classes/utils/Logger"
	require "classes/utils/Point"
	require "classes/utils/ExtendedMath"
	require "classes/gui/SideWindow"
	require "classes/entities/Dungeon"
	require "classes/entities/Perk"
	
	attr_accessor :inventory, :skills, :current_skill_points, :total_skill_points, :weapon, :armour, :sight, :killed, :killed_bosses, :perks, :gold, :level, :experience_points, :vortex_floor, :weapon_skills, :range_weapon_skills, :agility_additive, :quests, :game_time, :range_weapon, :auto_arrow_management, :name
	
	# where can I move these?
	attr_accessor :last_fired_at
	
	# a necessary evil of serializing and deserializing instances.
	def set_from(p)
		p.instance_variables.each do |x|
			self.instance_variable_set(x, p.instance_variable_get(x))
		end
		
		# some things shouldn't be persisted
		self.killed = []
		self.last_fired_at = nil
	end
	
	def symbol
		return "@"
	end
	
	def unequip_if_equipped(item)
		Player.instance.range_weapon.ammo = nil if item.is_a?(Ammo) && !Player.instance.range_weapon.nil? && Player.instance.range_weapon.ammo == item
		Player.instance.armour.delete_if {|key, value| value == item } if item.is_a?(Armour) && Player.instance.armour[item.subtype] == item
		Player.instance.weapon = nil if item.is_a?(Weapon) && Player.instance.weapon == item
		Player.instance.range_weapon = nil if item.is_a?(RangeWeapon) && Player.instance.range_weapon == item
	end
	
	def find_skill(skill_name)
		self.skills.each do |s|
			return s if s.name.downcase == skill_name.downcase
		end
		
		return nil
	end
	
	def initialize
		self.total_health = 20
		self.current_health = self.total_health
		self.strength = 12
		self.toughness = 8
		self.agility = 5
		self.total_skill_points = 5
		self.current_skill_points = self.total_skill_points
		self.inventory = Inventory.instance
		self.skills = []
		self.experience_points = 0
		self.level = 1
		self.is_seen = true
		self.sight = 4
		self.killed = []
		self.killed_bosses = []
		self.perks = []
		self.gold = 500
		self.vortex_floor = nil
		self.agility_additive = 0
		#self.weapon_skills are initialized in DataMaster.load_weapons
		self.quests = []
		self.weapon = nil
		self.armour = {} # key is subtype
		self.game_time = 0 # in seconds
		self.auto_arrow_management = false
	end
	
	def total_armour_defense
		total = 0
		
		self.armour.each_value {|armour|
			total += armour.defense
		}
		
		return total
	end
	
	def try_to_fire
		if (!self.last_fired_at.nil? && self.last_fired_at.is_alive? == true)
			cursor_x = self.last_fired_at.x
			cursor_y = self.last_fired_at.y
		elsif (!self.last_fired_at.nil? && self.last_fired_at.is_alive? == false)
			self.last_fired_at = nil
			closest = find_closest_visible_monster
			cursor_x = closest.x
			cursor_y = closest.y
		else
			closest = find_closest_visible_monster
			cursor_x = closest.x
			cursor_y = closest.y
		end

		MainWindow.instance.draw(true, cursor_x, cursor_y)		
		range = self.range_weapon.range
		
		key = InputHelper.read_char
		
		while key != Keys.ENTER && key != Keys.LOWERCASE_F && key != Keys.ESCAPE
			if key == Keys.LEFT && cursor_x - 1 >= 0 && is_in_range(cursor_x - 1, cursor_y, range)
				cursor_x -= 1
			elsif key == Keys.RIGHT && cursor_x + 1 < Dungeon.instance.width && is_in_range(cursor_x + 1, cursor_y, range)
				cursor_x += 1
			elsif key == Keys.UP && cursor_y - 1 >= 0 && is_in_range(cursor_x, cursor_y - 1, range)
				cursor_y -= 1
			elsif key == Keys.DOWN && cursor_y + 1 < Dungeon.instance.height && is_in_range(cursor_x, cursor_y + 1, range)
				cursor_y += 1
			end
			
			MainWindow.instance.draw(true, cursor_x, cursor_y)
			
			key = InputHelper.read_char
		end
		
		if key == Keys.ESCAPE
			MainWindow.instance.draw
			return false 
		end
	
		# FIRE!
		monster = Dungeon.instance.get_monster(cursor_x, cursor_y)
		if monster.nil?
			StatusBar.instance.show_message("There's nothing there!")
			MainWindow.instance.draw
			return false
		elsif ExtendedMath.distance_between(self.x, self.y, monster.x, monster.y) <= 1
			StatusBar.instance.show_message("Too close!")
		elsif ExtendedMath.distance_between(self.x, self.y, monster.x, monster.y) > self.range_weapon.range
			StatusBar.instance.show_message("#{monster.name} is out of range!")
			MainWindow.instance.draw
		elsif !Dungeon.instance.is_in_line_of_sight?(self.x, self.y, cursor_x, cursor_y)
			StatusBar.instance.show_message("You can't see there!")
			MainWindow.instance.draw
			return false
		else
			self.range_weapon.ammo.quantity -= num_shots(monster)
			monster = Dungeon.instance.get_monster(cursor_x, cursor_y)
			MainWindow.instance.show_arrow_firing(self, monster, num_shots(monster))
			attack(monster, true)
			self.last_fired_at = monster
		end
		
		if self.range_weapon.ammo.quantity == 0
			self.range_weapon.ammo = nil
			self.inventory.remove(self.range_weapon.ammo)			
				
			if self.auto_arrow_management == false
				StatusBar.instance.show_message("Out of ammo!")
			else
				self.range_weapon.ammo = find_arrows
				if self.range_weapon.ammo.nil?
					StatusBar.instance.show_message("Completely out of ammo!")
				else
					name = self.range_weapon.ammo.name
					name += " (+#{self.range_weapon.ammo.damage})" if self.range_weapon.ammo.identified == true
					StatusBar.instance.show_message("Switched to #{name}")
				end
			end
		end
		
		return true
	end
	
	def find_arrows
		self.inventory.contents.each do |i|
			if i.is_a?(Ammo) && i.quantity > 0 && (((self.range_weapon.subtype == "bow" || self.range_weapon.subtype == "longbow") && i.subtype == "arrow") || (self.range_weapon.subtype == "crossbow" && i.subtype == "bolt"))
				return i
			end
		end
		
		return nil
	end
	
	def current_weapon_skill
		return nil if self.weapon.nil?
		
		self.weapon_skills.each do |s|
			if s.subtype == self.weapon.subtype
				return s
			end
		end

		return nil
	end
	
	def current_range_weapon_skill
		return nil if self.range_weapon.nil?
		
		self.range_weapon_skills.each do |s|
			if s.subtype == self.range_weapon.subtype
				return s
			end
		end

		return nil
	end
	
	def attack(monster, is_shot = false)
		return if monster.nil? || monster.is_alive? == false
			
		if is_shot == false
			damage = damage_in_attack(monster)
		else
			damage = damage_in_shot(monster)
		end
		
		if damage < 0
			damage = 0
		end
		
		if damage == 0 && monster.name.include?("Aarij")
			StatusBar.instance.show_message("#{monster.name} is immune to shots!") 
			return
		end
		
		if (damage > 0)
			if is_shot == false
				self.current_weapon_skill.total_points += 1 unless self.weapon.nil?
				points = self.current_weapon_skill.total_points
				if points % 100 == 0
					StatusBar.instance.show_message("#{Player.instance.weapon.subtype} skill increases to level #{points / 100} [more]")
					InputHelper.read_char
				end
			else
				self.current_range_weapon_skill.total_points += 1 unless self.range_weapon.nil?
				points = self.current_range_weapon_skill.total_points 
				if points % 100 == 0
					StatusBar.instance.show_message("#{self.range_weapon.subtype} skill increases to level #{points / 100} [more]")
					InputHelper.read_char
				end
			end
		end
		
		if (is_shot == false)
			StatusBar.instance.show_player_attack_message(monster, damage)
		else
			shots_text = " with #{num_shots(monster)} shots" if num_shots(monster) > 1
			StatusBar.instance.show_message("Hit #{monster.name}#{shots_text} for #{damage} damage!")
		end
		
		monster.get_hurt(damage)
		
		if !monster.is_alive? && !self.killed?(monster)
			self.killed << monster.name if monster.is_boss == false
			self.killed_bosses << monster.name if monster.is_boss == true
		end
		
		SideWindow.instance.show_monster_health(monster)
	end
	
	def damage_in_attack(monster)
		damage = self.strength - monster.toughness
		damage += self.weapon.damage * (self.current_weapon_skill.level + 1) unless self.weapon.nil?
		return damage
	end
	
	def damage_in_shot(monster)
		if !monster.name.include?("Egg")
			damage_per_shot = self.strength - monster.toughness
		else
			# Eggs are succeptible to range weapons. For balancing.
			damage_per_shot = (monster.total_health * 0.1).to_i
		end
		
		damage_per_shot += self.range_weapon.ammo.damage unless self.range_weapon.nil?
		shots = num_shots(monster)
		# special case
		return 0 if monster.is_boss == true && monster.name.include?("Aarij")
		return damage_per_shot * shots
	end
	
	def num_shots(monster)
		base_shots = [self.current_range_weapon_skill.level + 1, self.range_weapon.ammo.quantity].min
		if is_in_sight(monster)
			return base_shots
		else
			distance = ExtendedMath.distance_between(self.x, self.y, monster.x, monster.y)
			return [(base_shots - (distance - self.sight)).to_i, 1].max # deduct one point for every squiare out of our sight; min is 1
		end
	end
	
	def get_hurt(damage)
		if damage.nil?
			raise "Damage cannot be nil"
		else
			if damage < 0
				damage = 0
			end
			self.current_health -= damage
			MainWindow.instance.show_hurt_star(self) if damage > 0
		end
	end
	
	def try_to_move(x, y)
		d = Dungeon.instance
		
		if d.is_closed_door?(x, y)
			d.open_door(x, y)
		elsif d.is_monster?(x, y)
			monster = d.get_monster(x, y)
			self.attack(monster)
		elsif d.is_person?(x, y)
			person = d.person_at(x, y)
			person.interact
		else
			# walkable
			super
		end
		
		self.agility_additive -= 1 if self.agility_additive > 0
	end
	
	def increment_skill_points
		self.current_skill_points += 0.1 * self.level
		if self.current_skill_points > self.total_skill_points
			self.current_skill_points = self.total_skill_points
		end
	end
	
	def is_dead?
		return self.current_health <= 0
	end
	
	def get_experience_points(num)
		if (num < 0)
			num = 0
		end
		self.experience_points += num
		check_for_level_up
	end
	
	def floor_is_in_sight(x, y)
		return true if Dungeon.instance.floor_num == 0 #optimization for town drawing
		return ExtendedMath.distance_between(x, y, self.x, self.y) <= self.sight &&
			Dungeon.instance.is_in_line_of_sight?(self.x, self.y, x, y)
	end
	
	def is_in_sight(o)
		return true if Dungeon.instance.floor_num == 0 #optimization for town drawing
		return ExtendedMath.distance_between(o.x, o.y, self.x, self.y) <= self.sight && # quick check
			Dungeon.instance.is_in_line_of_sight?(self.x, self.y, o.x, o.y) # detailed check
	end
	
	def stab(key, skill_level)
		case(key)
			when Keys.UP			
				return self.try_to_stab(self.x, self.y - 1, skill_level)
			when Keys.DOWN
				return self.try_to_stab(self.x, self.y + 1, skill_level)
			when Keys.LEFT
				return self.try_to_stab(self.x - 1, self.y, skill_level)
			when Keys.RIGHT
				return self.try_to_stab(self.x + 1, self.y, skill_level)
		end
	end
	
	def impale(key, skill_level)
		case(key)
			when Keys.UP			
				return self.try_to_impale(self.x, self.y - 1, skill_level)
			when Keys.DOWN
				return self.try_to_impale(self.x, self.y + 1, skill_level)
			when Keys.LEFT
				return self.try_to_impale(self.x - 1, self.y, skill_level)
			when Keys.RIGHT
				return self.try_to_impale(self.x + 1, self.y, skill_level)
		end
	end
	
	def try_to_stab(x, y, skill_level)
		target = Dungeon.instance.get_monster(x, y);
		if !target.nil?
			# super-stab!
			additive = self.strength + (skill_level + 1)
			self.strength += additive
			self.attack(target)
			self.strength -= additive #don't wipe out level-up boosts
			return true
		else
			return false
		end		
	end
	
	def try_to_impale(x, y, skill_level)
		target = Dungeon.instance.get_monster(x, y);
		if !target.nil?
			# super-stab!
			additive = self.strength + ((skill_level + 1) * 4)
			self.strength += additive
			self.attack(target)
			self.strength -= additive #don't wipe out level-up boosts
			return true
		else
			return false
		end
	end
	
	def killed?(monster)
		self.killed.each do |m|
			return true if m == monster.name
		end
		
		self.killed_bosses.each do |b|
			return true if b == monster.name
		end
		
		return false
	end
	
	def has_perk?(name)
		Player.instance.perks.each do |p|
			if p.name.upcase == name.upcase
				return true
			end
		end
		return false
	end
	
	def equip_item_for_key(key)
		self.inventory.contents.each do |i|
			if i.key.to_s == key.to_s
				if i.is_a?(RangeWeapon)
					self.range_weapon = i
					if i.identified
						StatusBar.instance.show_message("You've equipped #{i.name} (#{i.range}r).")
					else
						StatusBar.instance.show_message("You've equipped #{i.name}.")
					end
				elsif i.is_a?(Weapon) && !i.is_a?(Ammo)
					self.weapon = i
					if i.identified
						StatusBar.instance.show_message("You've equipped #{i.name} (+#{i.damage}).")
					else
						StatusBar.instance.show_message("You've equipped #{i.name}.")
					end
				elsif i.is_a?(Armour)
					self.armour[i.subtype] = i
					if i.identified
						StatusBar.instance.show_message("You've equipped #{i.name} (+#{i.defense}).")
					else
						StatusBar.instance.show_message("You've equipped #{i.name}.")
					end
				else
					StatusBar.instance.show_message("You can't equip #{i.name}!")
				
				end
			end
		end
	end
	
	def heal
		self.current_health += self.level
		if (self.current_health > self.total_health)
			self.current_health = self.total_health
		end
		
		self.increment_skill_points
	end
	
	def experience_points_for_next_level(offset = 0)
		effective_level = self.level + offset
		return 500 + (100 * effective_level * effective_level * effective_level) # 500 + 100n^3
	end
	
	def has_any_quests?
		return true if self.quests.length > 0
	end
	
	def has_quest?(name)
		self.quests.each do |q|
			return true if q.name.upcase == name.upcase
		end
		return false
	end
	
	def finished_quest?(name)
		return false if has_quest?(name) == false
		return get_quest(name).is_complete
	end
	
	def get_quest(name)
		self.quests.each do |q|
			return q if q.name.upcase == name.upcase
		end
		return nil
	end
	
	private
	
	def find_closest_visible_monster
		all = Dungeon.instance.monsters.to_array.sort {|a, b| ExtendedMath.distance_between(Player.instance.x, Player.instance.y, a.x, a.y) <=> ExtendedMath.distance_between(Player.instance.x, Player.instance.y, b.x, b.y)}
		
		all.each do |m|
			return Point.new(m.x, m.y) if !m.nil? && m.is_seen == true && is_in_sight(m) && ExtendedMath.distance_between(self.x, self.y, m.x, m.y) <= self.range_weapon.range
		end
		
		return Point.new(self.x, self.y)
	end
	
	def is_in_range(x, y, distance)
		return Math.sqrt(((x - self.x)**2) + ((y - self.y)**2)) <= distance
	end
	
	def check_for_level_up
		times_up = 0
		
		while (self.experience_points >= experience_points_for_next_level(times_up))
			times_up += 1
		end
		
		if times_up > 0
			StatusBar.instance.show_message("You gained a level!")
			level_up(times_up)
		end
	end
	
	def level_up(levels)
		times_up = levels + 0 #create a copy
		
		hp = sp = str = agi = tough = 0
		
		while (times_up > 0)
			# these don't come from points
			hp += self.level * 10
			sp += self.level * 5
			
			points = self.level * 5
			# what we benefitted
			# baseline at points/5 for each attribute
			str += points / 5
			agi += points / 5
			tough += points / 5
			
			points -= (str + agi + tough)		
			
			while (points > 0)
				# 50% chance of strength
				which = rand(4)
				if (which == 0 || which == 1)
					str += 1
				elsif (which == 2)
					tough += 1
				elsif (which == 3)
					agi += 1
				end
				points -= 1
			end
			
			self.sight += 1 if self.level % Globals.levels_per_sight_up == 0			
			self.level += 1
			times_up -= 1;
		end #while
			
		# bequeath!
		self.total_health += hp
		self.current_health += hp
		self.total_skill_points += sp
		self.current_skill_points += sp
		self.strength += str
		self.toughness += tough
		self.agility += agi
		
		SideWindow.instance.draw
		SideWindow.instance.show_levelup(levels, hp, sp, str, agi, tough);
		
		Perk.repository.each do |p|
			if (self.level >= p.level) && !self.has_perk?(p.name)
				self.perks << p
				StatusBar.instance.show_perk_gained(p)
			end
		end
	end	
end
