class DataMaster

	require "classes/entities/Monster"
	require "classes/entities/Item"
	require "classes/entities/Armour"
	require "classes/entities/Ammo"
	require "classes/entities/RangeWeapon"
	require "classes/entities/WeaponSkill"
	require "classes/entities/Quest"
	require "classes/entities/Game"
	
	@@items = []
	@@adjectives = []
	@@armour_adjectives = []
	@@creatures = []
	@@weapon_types = []
	@@ammo_types = []
	
	@@item_symbols = ['~', '`', '!', '^', '&', '(', ')', '-', '=', '|', "]",
						"[", "}", "{", ":", ";", '"', "'", "?"]
	
	def self.items
		@@items
	end
	
	def self.adjectives
		@@adjectives
	end
	
	def self.armour_adjectives
		@@armour_adjectives
	end
	
	def self.creatures
		@@creatures
	end
	
	def self.weapon_types
		@@weapon_types
	end
	
	def self.ammo_types
		@@ammo_types
	end
	
	def self.populate_repositories
		load_items
		load_adjectives
		
		load_creatures
		load_bosses
		load_skills
		load_weapons
		load_range_weapons
		load_ammo
		load_armour_adjectives
		load_armour
		load_perks
		load_quests
	end
	
	def self.load_adjectives
		File.open("data/adjectives.dat").each { |line|
			self.adjectives << line.strip.chomp
		}
	end
	
	def self.load_armour_adjectives
		File.open("data/armour_adjectives.dat").each { |line|
			self.armour_adjectives << line.strip.chomp
		}
	end
	
	def self.load_perks
		File.open("data/perks.dat").each { |line|
			line = line.strip.chomp
			first_comma = line.index(",")
			second_comma = line.index(",", first_comma + 1)
			
			name = line[0..first_comma - 1]
			description = line[first_comma + 2 .. second_comma - 1]
			level = line[second_comma + 2..-1]
			
			Perk.repository << Perk.new(name, description, level)
		}
	end
	
	def self.load_quests
		File.open("data/quests.dat").each { |line|
			line = line.strip.chomp
			first_comma = line.index(",")
			second_comma = line.index(",", first_comma + 1)
			third_comma = line.index(",", second_comma + 1)
			fourth_comma = line.rindex(",")
			
			name = line[0..first_comma - 1]
			level = line[first_comma + 2..second_comma - 1].to_i
			summary = line[second_comma + 2..third_comma - 1]
			description = line[third_comma + 2..fourth_comma -1]
			originator = line[fourth_comma + 2..-1]
			
			Quest.repository << Quest.new(name, level, summary, description, originator)
			Logger.log("Added quest: #{name}: #{description} (#{level}/#{originator})")
		}
		
		Quest.repository.sort {|x, y| x.level <=> y.level}
	end
	
	def self.load_weapons
		raw = []
		
		if Player.instance.weapon_skills.nil?
			set_weapon_skills = true
		end
		
		Player.instance.weapon_skills = [] if set_weapon_skills == true
		
		File.open("data/weapons.dat").each { |line|
			line = line.strip.chomp
			comma_pos = line.index(",")
			raw_name = line[0 .. comma_pos - 1]
			damage = line[comma_pos + 2 .. -1].to_i
			symbol = @@item_symbols[rand(@@item_symbols.length)]
			raw << Weapon.new("", raw_name, damage, symbol)
			Player.instance.weapon_skills << WeaponSkill.new(raw_name) if set_weapon_skills == true
			self.weapon_types << raw_name
		}
		
		n = 0
		num_uses = Globals.reuses_of_weapons * raw.length
		
		while n < num_uses
			i = rand(raw.length)
			subtype = raw[i].subtype #eg. sword
			adjective = self.adjectives[rand(self.adjectives.length)]
			name = "#{adjective} #{subtype}"
			
			damage = raw[i].damage
			# +- 50% variation
			if rand(2) == 0
				damage += rand(damage / 2).to_i
			else
				damage -= rand(damage / 2).to_i
			end
			
			# still generate SOMEWHAT weak weapons
			damage += (Player.instance.weapon.damage / 2).to_i unless Player.instance.weapon.nil?
			weapon = Weapon.new(name, subtype, damage, raw[i].symbol)
			
			while !Weapon.find(weapon).nil?
				# don't duplicate per full name (adj + type)
				subtype = raw[rand(raw.length)].subtype
				adjective = self.adjectives[rand(self.adjectives.length)]
				name = "#{adjective} #{subtype}"
				weapon = Weapon.new(name, subtype, damage, raw[i].symbol)
			end
			
			Logger.log("Added weapon: #{name} (#{damage}) #{raw[i].symbol} S=#{subtype}")
			Weapon.weapons << weapon
			n += 1
		
		end
	end
	
	def self.load_ammo
		raw = []
		
		File.open("data/ammo.dat").each { |line|
			line = line.strip.chomp
			comma_pos = line.index(",")
			raw_name = line
			symbol = @@item_symbols[rand(@@item_symbols.length)]
			raw << Ammo.new("", raw_name, 0, symbol)
			self.ammo_types << raw_name
		}
		
		base_damage = 10
		base_damage += Player.instance.range_weapon.ammo.damage unless Player.instance.range_weapon.nil? || Player.instance.range_weapon.ammo.nil?
		repos = []
		
		self.adjectives.each do |a|
			repos << a
		end
		
		repos.sort! {|a,b| rand(100) <=> rand(100) }
		
		repos.each do |adjective|
			raw.each do |i|
				subtype = i.subtype #eg. arrow
				name = "#{adjective} #{subtype}"
				damage = base_damage
				# +- 90% variation
				if rand(2) == 0
					damage += base_damage / 10
				else
					damage -= base_damage / 10
				end
				
				ammo = Ammo.new(name, subtype, damage, i.symbol)
				Logger.log("Added ammo: #{name} (#{damage}) #{i.symbol} S=#{subtype}")
				Ammo.ammo << ammo
				
				base_damage += 1
			end
		end
	end
	
	def self.load_range_weapons
		raw = []
		
		if Player.instance.range_weapon_skills.nil?
			set_range_weapon_skills = true
		end
		
		Player.instance.range_weapon_skills = [] if set_range_weapon_skills == true
		
		File.open("data/range_weapons.dat").each { |line|
			line = line.strip.chomp
			comma_pos = line.index(",")
			raw_name = line[0 .. comma_pos - 1]
			range = line[comma_pos + 2 .. -1].to_i
			symbol = @@item_symbols[rand(@@item_symbols.length)]
			Player.instance.range_weapon_skills << WeaponSkill.new(raw_name) if set_range_weapon_skills == true
			raw << RangeWeapon.new("", raw_name, range, symbol)
		}
		
		n = 0
		num_uses = Globals.reuses_of_range_weapons * raw.length
		
		while n < num_uses
			i = rand(raw.length)
			subtype = raw[i].subtype #eg. bow
			adjective = self.adjectives[rand(self.adjectives.length)]
			name = "#{adjective} #{subtype}"
			
			range = raw[i].range
			# +- 50% variation
			if rand(2) == 0
				range += rand(range / 2).to_i
			else
				range -= rand(range / 2).to_i
			end
			
			# still generate SOMEWHAT weak weapons
			range += (Player.instance.range_weapon.range / 2).to_i unless Player.instance.range_weapon.nil?
			weapon = RangeWeapon.new(name, subtype, range, raw[i].symbol)
			
			while !RangeWeapon.find(weapon).nil?
				# don't duplicate per full name (adj + type)
				subtype = raw[rand(raw.length)].subtype
				adjective = self.adjectives[rand(self.adjectives.length)]
				name = "#{adjective} #{subtype}"
				weapon = RangeWeapon.new(name, subtype, range, raw[i].symbol)
			end
			
			Logger.log("Added range weapon: #{name} (#{range}) #{raw[i].symbol} S=#{subtype}")
			RangeWeapon.range_weapons << weapon
			n += 1
		end
	end
	
	def self.load_armour
		raw = []
		
		File.open("data/armour.dat").each { |line|
		
			line = line.strip.chomp
			first_comma = line.index(",")
			second_comma = line.index(",", first_comma + 1)
			
			raw_name = line[0..first_comma - 1]
			subtype = line[first_comma + 2 .. second_comma - 1]
			defense = line[second_comma + 2 .. -1].to_i	
			
			symbol = @@item_symbols[rand(@@item_symbols.length)]
			raw << Armour.new(raw_name, subtype, defense, symbol)
		}
		
		n = 0
		num_uses = Globals.reuses_of_armour * raw.length
		
		
		while n < num_uses
			i = rand(raw.length)
			raw_name = raw[i].name
			adjective = self.armour_adjectives[rand(self.armour_adjectives.length)]
			name = "#{adjective} #{raw_name}"
			subtype = raw[i].subtype
			defense = raw[i].defense + rand(defense).to_i #100% variation
			defense += (Player.instance.armour[subtype].defense / 2) unless Player.instance.armour[subtype].nil?
			
			armour = Armour.new(name, raw[i].subtype, defense, raw[i].symbol)
			
			while !Armour.find(armour.name).nil?
				# don't duplicate per name/adjective pair
				raw_name = raw[rand(raw.length)].name
				adjective = self.armour_adjectives[rand(self.armour_adjectives.length)]
				name = "#{adjective} #{raw_name}"
				subtype = raw_name
				armour = Armour.new(name, raw[i].subtype, defense, raw[i].symbol)
			end
			
			Logger.log("Added armour: #{name} (#{raw[i].subtype}, #{defense}) #{raw[i].symbol}")
			Armour.armours << armour
			n += 1
		end
	end
	
	def self.load_skills
		File.open("data/skills.dat").each { |line|
			line = line.strip.chomp
			first_comma = line.index(",")
			second_comma = line.index(",", first_comma + 1)
			third_comma = line.index(",", second_comma + 1)
			fourth_comma = line.index(",", third_comma + 1)
			
			name = line[0..first_comma - 1]
			description = line[first_comma + 2..second_comma - 1]
			cost = line[second_comma + 2..third_comma - 1]
			key = line[third_comma + 2..fourth_comma - 1]
			logic = line[fourth_comma + 2..-1]
			
			if !cost.include?("%")
				cost = cost.to_i
			end
			
			s = Skill.new(name, description, cost, key, logic)
			Logger.log("Skill: name=#{name}, desc=#{description}, cost=#{cost} SP, key=#{key}, logic: #{logic}")
			Skill.repository << s
		}
		
	end
	
	def self.load_creatures
		points = 10
		i = 0
		
		File.open("data/creatures.dat").each { |line|
			self.creatures << line.strip.chomp
		}
		
		while Monster.repository.length < self.creatures.length * DataMaster.adjectives.length / 3 #1/3 per creature
			# chose randomly
			raw_name = self.creatures[rand(self.creatures.length)].chomp
			if i % 8 == 0
				points *= 2
				i = 0
			end
			symbol = raw_name[0, 1].downcase
			
			adjective = self.adjectives[rand(self.adjectives.length)]
			name = "#{adjective} #{raw_name}"
			
			while Monster.repository_has?(name)
				adjective = self.adjectives[rand(self.adjectives.length)]
				name = "#{adjective} #{raw_name}"
			end
			
			health = points;
			#put 25-50% into strength
			strength = (rand(0.25 * points) + (0.25 * points)).to_i
			# save at least 10% for agility
			toughness = rand(points - strength - 1 - (0.1 * points)) + 1
			agility = points - strength - toughness
			
			# reuse if more than 26 monsters
			while monster_symbol_used?(symbol) && Monster.repository.length < 26
				symbol = (rand(26) + 97).chr #a-z
			end
			
			Monster.repository << Monster.new(name, health, strength, agility, toughness, symbol)
			Logger.log("(#{points}) Added a monster #{name} / #{symbol}; h=#{health}, s=#{strength}, t=#{toughness}, a=#{agility} (total = #{(strength + toughness + agility)})");
			points += 10;
			i += 1
		end
	end
	
	def self.load_bosses
		# added on-demand by quests
		File.open("data/bosses.dat").each { |line|
			line = line.strip.chomp
			first_comma = line.index(",")
			second_comma = line.index(",", first_comma + 1)
			third_comma = line.index(",", second_comma + 1)
			fourth_comma = line.index(",", third_comma + 1)
			fifth_comma = line.index(",", fourth_comma + 1)
			sixth_comma = line.index(",", fifth_comma + 1)
			seventh_comma = line.rindex(",")
			
			
			name = line[0..first_comma - 1]
			health = line[first_comma + 2..second_comma - 1].to_i
			strength = line[second_comma + 2..third_comma - 1].to_i
			agility = line[third_comma + 2..fourth_comma - 1].to_i
			toughness = line[fourth_comma + 2..fifth_comma - 1].to_i
			symbol = line[fifth_comma + 2..sixth_comma - 1]
			item = eval(line[sixth_comma + 2..seventh_comma - 1])
			drop_percent = line[seventh_comma + 2.. -1].to_i
			
			Logger.log("Boss: name=#{name}, s=#{strength}, a=#{agility}, t=#{toughness}, hp: #{health}, i=#{item}, d=#{drop_percent}")
			Monster.bosses[name] = Monster.new(name, health, strength, agility, toughness, symbol, true, item, drop_percent)
		}
	end
	
	def self.monster_symbol_used?(symbol)
		Monster.repository.each do |m|
			if m.symbol == symbol
				return true
			end
		end
		return false
	end
	
	def self.load_items
		Item.items.clear
		
		File.open("data/items.dat").each { |line|
			line = line.strip.chomp
			name = line
			symbol = @@item_symbols[rand(@@item_symbols.length)]
			Item.items << Item.new(name, symbol)
			Logger.log("Adding item: #{name} #{symbol}");
		}
	end

	def self.assign_new_game_data
		Skill.repository.each do |s|
			Player.instance.skills << s
		end
		
		Player.instance.inventory.add(Armour.weakest)
		Player.instance.armour[Armour.weakest.subtype] = Armour.weakest
		
		Player.instance.inventory.add(Weapon.weakest)
		Player.instance.weapon = Weapon.weakest
		
		Game.instance.set_global("num_tentacles", rand(10) + 10)
		Game.instance.set_global("rescued_blacksmith", false)
		Game.instance.set_global("num_items_fused", 0)
		
		Person.generate_trader_items
		Person.generate_farrier_items
	end
	
end
