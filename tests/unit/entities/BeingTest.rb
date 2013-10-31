require "classes/entities/Being"
require "classes/entities/Player"

class BeingTest < Test::Unit::TestCase

	@@b = Being.new
	@@d = Dungeon.instance
	
	### try_to_move tests ###
	def test_try_to_move_walks_into_wall
		dungeon_setup
		@@b.try_to_move(@@b.x - 1, @@b.y - 1);
		assert_equal(@@b.x, 1)
		assert_equal(@@b.y, 1)
	end
	
	def test_try_to_move_walks_into_closed_door
		dungeon_setup
		start_x = @@b.x
		start_y = @@b.y
		d = @@d.doors[0]
		@@b.try_to_move(d.x, d.y)
		assert_equal start_x, @@b.x
		assert_equal start_y, @@b.y
	end
	
	def test_try_to_move_walks_over_open_door
		dungeon_setup
		@@b.try_to_move(@@b.x, @@b.y - 1); # open
		@@b.try_to_move(@@b.x, @@b.y - 1); # walk over
		assert_equal(1, @@b.x);
		assert_equal(1, @@b.y);
	end
	
	def test_try_to_move_walks_over_empty_floor
		dungeon_setup
		@@b.x = 3
		@@b.y = 3
		
		# walk down
		@@b.try_to_move(@@b.x, @@b.y + 1);
		assert_equal(3, @@b.x);
		assert_equal(4, @@b.y);
		# walk left
		@@b.try_to_move(@@b.x - 1, @@b.y);
		assert_equal(2, @@b.x);
		assert_equal(4, @@b.y);
		# walk up
		@@b.try_to_move(@@b.x, @@b.y - 1);
		assert_equal(2, @@b.x);
		assert_equal(3, @@b.y);
		# walk right
		@@b.try_to_move(@@b.x + 1, @@b.y);
		assert_equal(3, @@b.x);
		assert_equal(3, @@b.y);
	end
	
	def test_try_to_move_walks_over_stairs
		@@b.try_to_move(2, 0); # open
		assert_equal(@@b.x, 2);
		assert_equal(@@b.y, 0);
	end
	
	def test_try_to_move_on_map_edges_works
		@@d.width = 10;
		@@d.height = 5;
		
		assert_nothing_raised do
			@@b.try_to_move(0, 0);
			@@b.try_to_move(10, 5);
			@@b.try_to_move(0, 5);
			@@b.try_to_move(10, 0);
		end
	end
	
	def test_try_to_move_off_map_raises_error
		dungeon_setup
		
		assert_raise RuntimeError do
			@@b.try_to_move(-1, 2);
		end
		
		assert_raise RuntimeError do
			@@b.try_to_move(1, -2);
		end
		
		assert_raise RuntimeError do
			@@b.try_to_move(-1, -2);
		end
		
		assert_raise RuntimeError do
			@@b.try_to_move(@@d.width + 10, 2);
		end
		
		assert_raise RuntimeError do
			@@b.try_to_move(10, @@d.height + 20);
		end
	end
	
	def test_try_to_move_with_nil_x_raises_error
		dungeon_setup
		assert_raise RuntimeError do
			@@b.try_to_move(nil, @@b.y);
		end
	end
	
	def test_try_to_move_with_nil_y_raises_error
		dungeon_setup
		assert_raise RuntimeError do
			@@b.try_to_move(@@b.x, nil);
		end
	end
	
	def test_try_to_move_with_nil_x_y_raises_error
		dungeon_setup
		assert_raise RuntimeError do
			@@b.try_to_move(nil, nil);
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
		
		@@d.width = 5;
		@@d.height = 5;
		
		@@b.x = 1;
		@@b.y = 1;
	end
end
