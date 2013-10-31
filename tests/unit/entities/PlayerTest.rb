require "classes/entities/Being"
require "classes/entities/Player"
require "classes/entities/Monster"

class PlayerTest < Test::Unit::TestCase

	@@p = Player.instance
	@@m = nil
	@@d = Dungeon.instance

	def setup
		@@p = Player.instance
		@@m = Monster.new("Test Monster", 100, 7, 2, 3, "t")
	end
	
	### get_hurt method ###
	
	def test_get_hurt_does_nothing_with_negative_damage
		@@p.current_health = 20
		health = @@p.current_health
		@@p.get_hurt(-20)
		assert_equal(@@p.current_health, health)
	end
	
	def test_get_hurt_does_nothing_with_zero_damage
		@@p.current_health = 20
		health = @@p.current_health
		@@p.get_hurt(0)
		assert_equal(@@p.current_health, health)
	end
	
	def test_get_hurt_damages_with_positive_damage
		@@p.current_health = 20
		health = @@p.current_health
		@@p.get_hurt(5)
		assert_equal(@@p.current_health, health - 5)
	end
	
	def test_get_hurt_raises_error_with_nil_damage
		@@p.current_health = 20
		health = @@p.current_health
		assert_raise RuntimeError do
			@@p.get_hurt(nil)
		end
	end
	
	def test_get_hurt_can_kill_player_with_damage_equal_to_health
		@@p.current_health = 20
		health = @@p.current_health
		@@p.get_hurt(20)
		assert_equal(@@p.current_health, 0)
		assert_equal @@p.is_dead?, true
	end
	
	def test_get_hurt_can_kill_player_with_damage_greater_than_health
		@@p.current_health = 20
		health = @@p.current_health
		@@p.get_hurt(25)
		assert_equal(@@p.current_health, -5)
		assert_equal @@p.is_dead?, true
	end
	
	### is_dead method ###
	
	def test_is_dead_returns_true_with_zero_health
		@@p.current_health = 0;
		@@p.total_health = 3;
		assert_equal @@p.is_dead?, true
	end
	
	def test_is_dead_returns_true_with_negative_health
		@@p.current_health = -10;
		@@p.total_health = 3;
		assert_equal @@p.is_dead?, true
	end
	
	def test_is_dead_returns_false_with_positive_health
		@@p.current_health = 1;
		@@p.total_health = 30;
		assert_equal @@p.is_dead?, false
	end
	
	def test_is_dead_returns_false_with_current_health_above_max_health
		@@p.current_health = 10;
		@@p.total_health = 3;
		assert_equal @@p.is_dead?, false
	end
	
	### attack(m) method ###
	
	def test_attack_damage_equals_strength_minus_monster_toughness
		@@p.strength = 7;
		@@p.attack(@@m);
		assert_equal @@m.current_health, 96 # 100 - (7 - 3) = 100 - 4 = 96
	end
	
	def test_attack_damage_is_zero_if__damage_calculated
		# zero damage when p.strength < m.toughness
		@@m.toughness = 30;
		@@p.strength = 7;
		@@p.attack(@@m);
		assert_equal @@m.current_health, 100
	end
	
	def test_attack_raises_error_with_nil_monster
		m = nil;
		assert_raise RuntimeError do
			@@p.attack(m)
		end
	end
	
	### try_to_move tests ###
	def test_try_to_move_walks_into_wall
		dungeon_setup
		@@p.try_to_move(@@p.x - 1, @@p.y - 1);
		assert_equal(@@p.x, 1)
		assert_equal(@@p.y, 1)
	end
	
	def test_try_to_move_walks_into_closed_door
		dungeon_setup
		start_x = @@p.x
		start_y = @@p.y
		d = @@d.doors[0]
		@@p.try_to_move(d.x, d.y)
		assert_equal start_x, @@p.x
		assert_equal start_y, @@p.y
	end
	
	def test_try_to_move_attacks_monster
		dungeon_setup
		@@p.try_to_move(@@p.x + 2, @@p.y - 1);
		# FIGHT! Worked if monster health decreased from 100
		assert_not_equal @@m.current_health, 100
	end
	
	def test_try_to_move_opens_closed_door
		dungeon_setup
		Dungeon.instance.doors[0].is_open = false
		@@p.try_to_move(@@p.x, @@p.y - 1);
		assert_equal Dungeon.instance.doors[0].is_open?, true
	end
	
	def test_try_to_move_walks_over_open_door
		dungeon_setup
		@@p.try_to_move(@@p.x, @@p.y - 1); # open
		@@p.try_to_move(@@p.x, @@p.y - 1); # walk over
		assert_equal(@@p.x, 1);
		assert_equal(@@p.y, 0);
	end
	
	def test_try_to_move_walks_over_empty_floor
		dungeon_setup
		# walk down
		@@p.try_to_move(@@p.x, @@p.y + 1);
		assert_equal(@@p.x, 1);
		assert_equal(@@p.y, 2);
		# walk left
		@@p.try_to_move(@@p.x - 1, @@p.y);
		assert_equal(@@p.x, 0);
		assert_equal(@@p.y, 2);
		# walk up
		@@p.try_to_move(@@p.x, @@p.y - 1);
		assert_equal(@@p.x, 0);
		assert_equal(@@p.y, 1);
		# walk right
		@@p.try_to_move(@@p.x + 1, @@p.y);
		assert_equal(@@p.x, 1);
		assert_equal(@@p.y, 1);
	end
	
	def test_try_to_move_walks_over_stairs
		@@p.try_to_move(2, 0); # open
		assert_equal(@@p.x, 2);
		assert_equal(@@p.y, 0);
	end
	
	def test_try_to_move_on_map_edges_works
		@@d.width = 10;
		@@d.height = 5;
		
		assert_nothing_raised do
			@@p.try_to_move(0, 0);
			@@p.try_to_move(10, 5);
			@@p.try_to_move(0, 5);
			@@p.try_to_move(10, 0);
		end
	end
	
	def test_try_to_move_off_map_raises_error
		dungeon_setup
		
		assert_raise RuntimeError do
			@@p.try_to_move(-1, 2);
		end
		
		assert_raise RuntimeError do
			@@p.try_to_move(1, -2);
		end
		
		assert_raise RuntimeError do
			@@p.try_to_move(-1, -2);
		end
		
		assert_raise RuntimeError do
			@@p.try_to_move(@@d.width + 10, 2);
		end
		
		assert_raise RuntimeError do
			@@p.try_to_move(10, @@d.height + 20);
		end
	end
	
	def test_try_to_move_with_nil_x_raises_error
		dungeon_setup
		assert_raise RuntimeError do
			@@p.try_to_move(nil, @@p.y);
		end
	end
	
	def test_try_to_move_with_nil_y_raises_error
		dungeon_setup
		assert_raise RuntimeError do
			@@p.try_to_move(@@p.x, nil);
		end
	end
	
	def test_try_to_move_with_nil_x_y_raises_error
		dungeon_setup
		assert_raise RuntimeError do
			@@p.try_to_move(nil, nil);
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
		@@m.x = 3;
		@@m.y = 0;
		
		@@d.width = 5;
		@@d.height = 5;
		
		Player.instance.x = 1;
		Player.instance.y = 1;
	end
end
