class Monster < Being

	attr_accessor :name, :symbol, :times_attacked, :total_damage, :is_boss, :boss_item, :boss_drop_percent
	
	require "classes/entities/Being"
	require "classes/utils/DirectionNode"
	require "classes/gui/StatusBar"
	
	@@repository = []
	@@bosses = {}
	
	def self.repository
		@@repository
	end
	
	def self.bosses
		@@bosses
	end
	
	def self.random_monster(min_index = 0, max_index = Monster.repository.length)
		if (min_index.nil? || max_index.nil? || min_index > max_index || min_index < 0 || max_index < 0 || min_index >= Monster.repository.length || max_index >= Monster.repository.length)
			raise "Min, max (#{min_index}, #{max_index}) must be non-nil in the range [0 ... #{Monster.repository.length - 1}]"
		else
			num = rand(max_index) + min_index
			if (num < min_index)
				num = min_index
			elsif num >= Monster.repository.length
				num = Monster.repository.length - 1
			end
			Monster.repository[num]
		end
	end
	
	def self.repository_has?(name)
		Monster.repository.each do |m|
			if m.name == name
				return true
			end
		end
		
		return false
	end
	
	def initialize(name, health, strength, agility, toughness, symbol, is_boss = false, boss_item = nil, boss_drop_percent = 0)
		self.name = name
		self.current_health = health
		self.total_health = health
		self.strength = strength
		self.toughness = toughness
		self.agility = agility
		self.symbol = symbol
		self.times_attacked = 0
		self.total_damage = 0
		@movement_points = 0
		self.is_boss = is_boss
		self.boss_item = boss_item
		self.boss_drop_percent = boss_drop_percent
		self.visible = true
	end
	
	def try_to_move(x, y)
		d = Dungeon.instance
		p = Player.instance
		
		if p.x == x && p.y == y
			self.attack
		else
			super
		end

		super
	end
	
	def move
		if !self.is_alive?
			return
		end
		
		p = Player.instance
		
		@movement_points += self.agility
		
		num_moves = 0
		
		while @movement_points >= p.agility + p.agility_additive
			@movement_points -= (p.agility + p.agility_additive)
			num_moves += 1
		end
		
		#path = DirectionNode.get_path_for(self, num_moves)
		
		### SPECIAL CASE: Mage23 ###
		if self.is_boss == true && self.name.include?("Aarij") && ExtendedMath.distance_between(self.x, self.y, Player.instance.x, Player.instance.y) <= 5 && Dungeon.instance.is_in_line_of_sight?(self.x, self.y, Player.instance.x, Player.instance.y)
			# HURL FIREBALL
			MainWindow.instance.show_arrow_firing(self, Player.instance, num_moves, true, [COLOR_RED, COLOR_YELLOW])
			self.attack(true)
		else
		
			while (num_moves > 0)
=begin
				move = path.shift
				
				case(move)
					when DirectionNode.UP
						self.try_to_move(self.x, self.y - 1)
					when DirectionNode.RIGHT
						self.try_to_move(self.x + 1, self.y)
					when DirectionNode.DOWN
						self.try_to_move(self.x, self.y + 1)
					when DirectionNode.LEFT
						self.try_to_move(self.x - 1, self.y)
				end
=end	
		
					# Indexed by XY; need to readd ourselves
					Dungeon.instance.monsters.delete_at(self.x, self.y) if num_moves > 0

					target_x = Player.instance.x
					target_y = Player.instance.y

					if (self.x != target_x && self.y != target_y)
						flip = rand(2) # 0 or 1
						if flip == 0
							# move horizontally
							if (target_x < self.x)
								self.try_to_move(self.x - 1, self.y)
							else 
								self.try_to_move(self.x + 1, self.y)
							end
						else
							# move vertically
							if (target_y < self.y)
								self.try_to_move(self.x, self.y - 1)
							else
								self.try_to_move(self.x, self.y + 1)
							end
						end
					elsif (self.x == target_x && self.y != target_y)
						# move vertically
						if (target_y < self.y)
							self.try_to_move(self.x, self.y - 1)
						else
							self.try_to_move(self.x, self.y + 1)
						end
					else
						# move horizontally
						if (target_x < self.x)
							self.try_to_move(self.x - 1, self.y)
						else 
							self.try_to_move(self.x + 1, self.y)
						end	
					end
				num_moves -= 1
			end #num-moves loop
			
			# Indexed by XY; need to readd ourselves
			Dungeon.instance.monsters.add(self)
		end
	end
	
	# approximation, used only for danger-sense
	def num_attacks
		return [self.agility / Player.instance.agility, 1].max
	end
	
	def attack(is_shot = false)
		p = Player.instance
		if is_shot == false
			damage = damage_in_attack
		else
			damage = damage_in_shot
		end
		if damage < 0
			damage = 0
		end
		self.total_damage += damage
		p.get_hurt(damage)
		s = StatusBar.instance
		s.show_monster_attack_message(self, damage)
	end
	
	def damage_in_attack
		attack = self.strength
		defend = Player.instance.toughness + Player.instance.total_armour_defense
		return attack - defend
	end
	
	def damage_in_shot
		return (0.75 * damage_in_attack).to_i
	end
	
	def is_mobile?
		return self.is_alive?
	end
	
	def get_hurt(damage)
		if !self.is_alive?
			Dungeon.instance.remove_monster(self)
		elsif damage.nil?
			damage = 0
		else
			if damage < 0
				damage = 0
			end
			
			# prevent farming. Increment in attack, or if you can do damage and player does 0 damage.
			self.times_attacked += 1 unless damage <= 0 || (damage == 0 && self.damage_in_attack > 0)
			if damage <= self.current_health
				self.total_damage += damage 
			else
				self.total_damage += self.current_health # avoid harvesting by overkilling weaklings
			end
			
			self.current_health -= damage
			MainWindow.instance.show_hurt_star(self) unless Skill.using_whirlwind == true
			
			if self.is_alive? == false
				# Dead!
				if self.name == "Hive Queen"
					Game.instance.set_global("endgame", true)
					StatusBar.instance.show_message("You defeated the #{self.name}! [more]")
					InputHelper.read_char
					return
				end
				
				experience = self.times_attacked * self.total_damage #(self.strength + self.toughness)
				Dungeon.instance.remove_monster(self)
				StatusBar.instance.show_monster_death(self, experience)
				Player.instance.get_experience_points(experience)
				if self.is_boss == false
					self.try_to_drop_something
				else
					if rand(100) + 1 < self.boss_drop_percent
						self.boss_item.x = self.x
						self.boss_item.y = self.y
						Dungeon.instance.items << self.boss_item
					end
					
					Dungeon.instance.get_stairs_down.visible = true unless Dungeon.instance.floor_num == 30
					StatusBar.instance.show_message("The stairs appear!") unless Dungeon.instance.floor_num == 30
				end
			else
				return if damage == 0
				
				# special case
				if self.name.include?("Aarij")
					Dungeon.instance.monsters.delete_at(self.x, self.y)
					xy = Dungeon.instance.generate_random_clear_x_y
					x = xy["x"]
					y = xy["y"]					
					dist = ExtendedMath.distance_between(Player.instance.x, Player.instance.y, x, y)
					
					while !Dungeon.instance.is_clear?(x, y) || dist < 3 || dist > 7
						xy = Dungeon.instance.generate_random_clear_x_y
						x = xy["x"]
						y = xy["y"]
						dist = ExtendedMath.distance_between(Player.instance.x, Player.instance.y, x, y)
					end
					
					self.visible = false
					
					# Strong! Dungeon generates from -1 to +2
					m = Monster.random_monster(Dungeon.instance.floor_num + 3, Dungeon.instance.floor_num + 4)
					m.x = self.x
					m.y = self.y
					
					self.x = xy["x"]
					self.y = xy["y"]
					
					Dungeon.instance.monsters.add(m)
					
					StatusBar.instance.show_message("#{self.name} teleports and summons a #{m.name}! [more]")
					InputHelper.read_char
					
					# just incase
					Player.instance.last_fired_at = nil
					Dungeon.instance.monsters.add(self)
				end
			end
			
			# Special case: Decalotupus Tentacles decrement in count
			if (self.name == "Decalotupus Tentacle")
				num_tentacles = Dungeon.instance.monsters.length
				num_tentacles -= 1 if Player.instance.killed?(Monster.bosses["Decalotupus"])
				Game.instance.set_global("num_tentacles", num_tentacles)
			end
			
			SideWindow.instance.draw # update on death: updates monster count, HP display
		end
	end
	
	def try_to_drop_something
		# try weapon-drop first
		if rand(100) <= Globals.monster_weapon_drop			
			n = 0
			while n < 10 # try 10 times
				if rand(100) < 50
					i = Weapon.random_weapon
				else
					i = Armour.random_armour
				end
				
				upper = (Dungeon.instance.floor_num * 5) + 10
				if (i.is_a?(Weapon) && i.damage <= upper) || (i.is_a?(Armour) && i.defense <= upper)
					i.x = self.x
					i.y = self.y
					Dungeon.instance.items << i
					return
				end
				n += 1
			end
			# if no weapon dropped, try item drop
		elsif rand(100) <= Globals.monster_item_drop
			Dungeon.instance.items << Item.random_item(self.x, self.y)
		end
	end
end
