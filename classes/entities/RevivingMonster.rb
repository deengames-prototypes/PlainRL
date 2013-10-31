class RevivingMonster < Monster

	@revive_percent = 10 # revive if health < -10%
	
	def initialize(name, health, strength, agility, toughness, symbol, revive_percent = 10, is_boss = false, boss_item = nil, boss_drop_percent = 0)
		@revive_percent = revive_percent
		super(name, health, strength, agility, toughness, symbol, is_boss, boss_item, boss_drop_percent)
	end
	
	def is_alive?
		# eg. 10% on 2000HP, we must be -200 or more to be dead
		return current_health > -(@revive_percent / 100.00) * self.total_health
	end
	
	def get_hurt(damage)
		super(damage)
		StatusBar.instance.show_message("#{self.name} is stunned! [more]") 
	end
	
	def is_mobile?
		return self.current_health > 0
	end
	
	def move
		old_health = self.current_health
		
		if self.is_mobile?
			super
			self.current_health += ([self.total_health * 0.03, 100].max).to_i
		elsif !self.is_mobile? && self.is_alive?
			self.current_health += ([self.total_health * 0.05, 100].max).to_i
		end
		
		self.current_health = [self.current_health, self.total_health].min
		
		if (old_health < 0 && self.current_health > 0)
			StatusBar.instance.show_message("#{self.name} revived!")
			SideWindow.instance.show_monster_health(self)
		end
		
		# why this constant? Because with 3-4 hits to kill, it's managable; otherwise; it goes WILD. Same with limit of 100.
		if self.name.downcase.include?("weed") && rand(250) <= 1 && Dungeon.instance.monsters.length < 100
			# try 10 times
			tries = 0
			xy = Dungeon.instance.generate_random_clear_x_y
			while ExtendedMath.distance_between(xy["x"], xy["y"], self.x, self.y) <= 10 && tries < 10
				xy = Dungeon.instance.generate_random_clear_x_y
				tries += 1
			end
			
			if tries < 10
				m = Copier.create_deep_copy(self)
				m.x = xy["x"]
				m.y = xy["y"]
				# handicapped: it's max is my current HP
				m.total_health = self.current_health
				m.current_health = m.total_health
				
				Dungeon.instance.monsters.add(m)
				StatusBar.instance.show_message("#{m.name} grew!")
			end
		end
	end
end