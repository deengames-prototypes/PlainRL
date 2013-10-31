class HiveQueen < Monster
	
	require "classes/entities/MonsterEgg"
	
	def initialize
		super("Hive Queen", Player.instance.total_health * 25, Player.instance.toughness * 3, Player.instance.agility * (rand(2) + 2), Player.instance.toughness * 2, "Q", true)
	end
	
	def move
		self.current_health += (self.total_health * 0.02).to_i
		self.current_health = self.total_health if self.current_health > self.total_health
		
		@movement_points += self.agility
		num_moves = 0
		
		while @movement_points >= Player.instance.agility + Player.instance.agility_additive
			@movement_points -= (Player.instance.agility + Player.instance.agility_additive)
			num_moves += 1
		end

		while (num_moves > 0)
		
			if rand(100) <= 45 #45% chance of egg-laying
				point = Dungeon.instance.generate_adjacent_clear_x_y(self.x, self.y)
				if !point.nil?
					egg = MonsterEgg.new
					egg.x = point.x
					egg.y = point.y
					Dungeon.instance.monsters.add(egg)
					StatusBar.instance.show_message("#{self.name} lays an egg!")
				end
			else
				# Indexed by XY; need to readd ourselves
				Dungeon.instance.monsters.delete_at(self.x, self.y) if num_moves > 0
				if rand(2) == 0
					# move horizontally
					if rand(2) == 0
						self.try_to_move(self.x - 1, self.y)
					else 
						self.try_to_move(self.x + 1, self.y)
					end
				else
					# move vertically
					if rand(2) == 0
						self.try_to_move(self.x, self.y - 1)
					else
						self.try_to_move(self.x, self.y + 1)
					end
				end
				num_moves -= 1
			end #num-moves loop
			
			# Indexed by XY; need to readd ourselves
			Dungeon.instance.monsters.add(self)
		end
	end
end