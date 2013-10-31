class MonsterEgg < Monster
	@turns_passed = 0
	
	def initialize
		super("Egg", Player.instance.total_health, 0, Player.instance.agility, Player.instance.toughness * 4, "o")
		@turns_passed = 0
	end
	
	def move
		@turns_passed += 1
		if @turns_passed >= rand(5) + 5 # 5-10
			# Strong!
			m = Monster.random_monster(Dungeon.instance.floor_num + 2, Dungeon.instance.floor_num + 3)
			m.x = self.x
			m.y = self.y
			
			# 75%-dead egg hatches into 75%-dead monster
			health_percent = self.current_health * 1.0 / self.total_health			
			m.current_health = health_percent * m.total_health
			
			Dungeon.instance.remove_monster(self)
			Dungeon.instance.monsters.add(m)
			StatusBar.instance.show_message("#{self.name} hatches into a #{m.name}!")
			MainWindow.instance.show_egg_hatch_star(m)
		end
	end
	
end