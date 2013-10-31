require "classes/entities/Monster"
require "classes/entities/Dungeon"

class MonsterTest < Test::Unit::TestCase

	@@d = Dungeon.instance

	def setup
		@@m = Monster.new("test", 10, 3, 2, 1, "t")
	end

	### initialize_monsters ###
	
	def test_initialize_monsters_creates_monsters
		Monster.initialize_monsters
		assert_not_equal Monster.repository.size, 0
	end
	
	def test_initialize_monsters_creates_bosses
		Monster.initialize_monsters
		assert_not_equal Monster.bosses.size, 0
	end
	
	def test_new_monster_is_alive
		assert_equal @@m.alive, true
	end
	
	### get_hurt ###
	
	def test_get_hurt_does_nothing_with_negative_damage
		@@m.current_health = 20
		health = @@m.current_health
		@@m.get_hurt(-20)
		assert_equal(@@m.current_health, health)
	end
	
	def test_get_hurt_does_nothing_with_zero_damage
		@@m.current_health = 20
		health = @@m.current_health
		@@m.get_hurt(0)
		assert_equal(@@m.current_health, health)
	end
	
	def test_get_hurt_damages_with_positive_damage
		@@m.current_health = 20
		health = @@m.current_health
		@@m.get_hurt(5)
		assert_equal(@@m.current_health, health - 5)
	end
	
	def test_get_hurt_raises_error_with_nil_damage
		@@m.current_health = 20
		health = @@m.current_health
		assert_raise RuntimeError do
			@@m.get_hurt(nil)
		end
	end
	
	### attack ###
	
	def test_attack_damage_equals_strength_minus_player_toughness
		p = Player.instance
		p.current_health = 100
		p.toughness = 3
		
		@@m.strength = 7;
		@@m.attack
		assert_equal p.current_health, 96 # 100 - (7 - 3) = 100 - 4 = 96
	end
	
	def test_attack_damage_is_zero_if__damage_calculated
		# zero damage when p.strength < m.toughness
		p = Player.instance
		p.current_health = 100
		p.toughness = 30
		
		@@m.strength = 7;
		@@m.attack
		assert_equal p.current_health, 100
	end
	
	### try_to_move ###
	
	def test_try_to_move_walks_into_wall
		dungeon_setup
		@@m.try_to_move(@@m.x - 1, @@m.y - 1);
		assert_equal(@@m.x, 1)
		assert_equal(@@m.y, 1)
	end
	
	def test_try_to_move_walks_into_closed_door
		dungeon_setup
		start_x = @@m.x
		start_y = @@m.y
		d = @@d.doors[0]
		@@m.try_to_move(d.x, d.y)
		assert_equal start_x, @@m.x
		assert_equal start_y, @@m.y
	end
	
	def test_try_to_move_attacks_player
		@@m.strength = 100;
		dungeon_setup
		Player.instance.current_health = 100
		@@m.try_to_move(Player.instance.x, Player.instance.y);
		# FIGHT! Worked if monster health decreased from 100
		assert_not_equal Player.instance.current_health, 100
	end
	
	def test_try_to_move_does_not_open_closed_door
		dungeon_setup
		door = Dungeon.instance.doors[0]
		door.is_open = false
		@@m.try_to_move(door.x, door.y);
		assert_equal door.is_open?, false
	end
	
	def test_try_to_move_walks_over_open_door
		dungeon_setup
		door = Dungeon.instance.doors[0]
		door.is_open = true
		@@m.try_to_move(door.x, door.y); # open
		assert_equal(door.x, @@m.x);
		assert_equal(door.y, @@m.y);
	end
	
	def test_try_to_move_walks_over_empty_floor
		dungeon_setup
		# walk down
		@@m.try_to_move(@@m.x, @@m.y + 1);
		assert_equal(@@m.x, 1);
		assert_equal(@@m.y, 2);
		# walk left
		@@m.try_to_move(@@m.x - 1, @@m.y);
		assert_equal(@@m.x, 0);
		assert_equal(@@m.y, 2);
		# walk up
		@@m.try_to_move(@@m.x, @@m.y - 1);
		assert_equal(@@m.x, 0);
		assert_equal(@@m.y, 1);
		# walk right
		@@m.try_to_move(@@m.x + 1, @@m.y);
		assert_equal(@@m.x, 1);
		assert_equal(@@m.y, 1);
	end
	
	def test_try_to_move_walks_over_stairs
		@@m.try_to_move(2, 0);
		assert_equal(@@m.x, 2);
		assert_equal(@@m.y, 0);
	end
	
	def test_try_to_move_on_map_edges_works
		@@d.width = 10;
		@@d.height = 5;
		
		assert_nothing_raised do
			@@m.try_to_move(0, 0);
			@@m.try_to_move(10, 5);
			@@m.try_to_move(0, 5);
			@@m.try_to_move(10, 0);
		end
	end
	
	def test_try_to_move_off_map_raises_error
		dungeon_setup
		
		assert_raise RuntimeError do
			@@m.try_to_move(-1, 2);
		end
		
		assert_raise RuntimeError do
			@@m.try_to_move(1, -2);
		end
		
		assert_raise RuntimeError do
			@@m.try_to_move(-1, -2);
		end
		
		assert_raise RuntimeError do
			@@m.try_to_move(@@d.width + 10, 2);
		end
		
		assert_raise RuntimeError do
			@@m.try_to_move(10, @@d.height + 20);
		end
	end
	
	def test_try_to_move_with_nil_x_raises_error
		dungeon_setup
		assert_raise RuntimeError do
			@@m.try_to_move(nil, @@m.y);
		end
	end
	
	def test_try_to_move_with_nil_y_raises_error
		dungeon_setup
		assert_raise RuntimeError do
			@@m.try_to_move(@@m.x, nil);
		end
	end
	
	def test_try_to_move_with_nil_x_y_raises_error
		dungeon_setup
		assert_raise RuntimeError do
			@@m.try_to_move(nil, nil);
		end
	end
	
	### helper methods ###
	def dungeon_setup
		@@d.walls = XYIndexedCollection.new
		@@d.walls.add(Wall.new(0, 0));
		@@d.doors = []
		@@d.doors << Door.new(1, 0)
		@@d.stairs = []
		@@d.stairs << Stairs.new(2, 0);
		@@d.monsters = []
		@@d.monsters << @@m
		@@m.x = 1;
		@@m.y = 1;
		
		@@d.width = 5;
		@@d.height = 5;
		
		Player.instance.x = 3;
		Player.instance.y = 0;
	end
	
	### random_monster ###
	
	def test_random_monster_returns_element_with_min_equal_max
		m = Monster.random_monster(0, 0)
		assert_equal m, Monster.repository[0]
	end
	
	def test_random_monster_returns_min_to_max_all_inclusive
		m = []
		while (m.length < 3)
			i = Monster.random_monster(1, 3)
			if !m.include?(i)
				m << i
			end
		end
		
		assert_equal m.length, 3
		assert_equal true, m.include?(Monster.repository[1])
		assert_equal true, m.include?(Monster.repository[2])
		assert_equal true, m.include?(Monster.repository[3])
	end
	
	def test_random_monster_never_goes_outside_min_to_max
		tries = 1000 #1000 tries for 3 monsters
		
		m = []
		while (tries > 0)
			i = Monster.random_monster(1, 3)
			if !m.include?(i)
				m << i
			end
			tries -= 1
		end
		
		# M has only monsters [1..3]
		assert_equal m.length, 3
		assert_equal true, m.include?(Monster.repository[1])
		assert_equal true, m.include?(Monster.repository[2])
		assert_equal true, m.include?(Monster.repository[3])
	end
	
	def test_random_monster_gets_last_monster_with_min_max_equal_repository_size
		index = Monster.repository.length - 1
		expected = Monster.repository[index]
		actual = Monster.random_monster(index, index)
		assert_equal expected, actual
	end
	
	def test_random_monster_raises_error_with_min_greater_than_max
		assert_raise RuntimeError do
			Monster.random_monster(20, 2)
		end
	end
	
	def test_random_monster_raises_error_with_negative_min
		assert_raise RuntimeError do
			Monster.random_monster(-1, 2)
		end
	end
	
	def test_random_monster_raises_error_with_negative_max
		assert_raise RuntimeError do
			Monster.random_monster(1, -2)
		end
	end
	
	def test_random_monster_raises_error_with_negative_min_max
		assert_raise RuntimeError do
			Monster.random_monster(-2, -1)
		end
	end
	
	def test_random_monster_raises_error_with_negative_min
		assert_raise RuntimeError do
			Monster.random_monster(-1, 2)
		end
	end
	
	def test_random_monster_raises_error_with_negative_max
		assert_raise RuntimeError do
			Monster.random_monster(1, -2)
		end
	end
	
	def test_random_monster_raises_error_with_negative_min_max
		assert_raise RuntimeError do
			Monster.random_monster(-2, -1)
		end
	end
	
	def test_random_monster_raises_error_with_nil_max
		assert_raise RuntimeError do
			Monster.random_monster(1, nil)
		end
	end
	
	def test_random_monster_raises_error_with_nil_min_max
		assert_raise RuntimeError do
			Monster.random_monster(nil, nil)
		end
	end
	
	def test_random_monster_raises_error_with_min_greater_than_repo_size
		assert_raise RuntimeError do
			Monster.random_monster(Monster.repository.length * 2, 5)
		end
	end
	
	def test_random_monster_raises_error_with_max_greater_than_repo_size
		assert_raise RuntimeError do
			Monster.random_monster(0, Monster.repository.length * 2)
		end
	end
	
	def test_random_monster_raises_error_with_min_max_greater_than_repo_size
		assert_raise RuntimeError do
			Monster.random_monster(Monster.repository.length * 2, Monster.repository.length * 3)
		end
	end
end
