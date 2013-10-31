require "classes/entities/Door"

class DoorTest < Test::Unit::TestCase

	@@d = nil

	def test_door_accepts_small_x_y
		assert_nothing_raised do
			@@d = Door.new(3, 4);
		end
	end
	
	def test_door_accepts_zero_x_y
		assert_nothing_raised do
			@@d = Door.new(0, 0);
		end
	end
	
	def test_door_rejects_negative_x
		assert_raise RuntimeError do
			@@d = Door.new(-2, 3);
		end
	end
	
	def test_door_rejects_nil_x
		assert_raise RuntimeError do
			@@d = Door.new(nil, 3);
		end
	end
	
	def test_door_rejects_negative_y
		assert_raise RuntimeError do
			@@d = Door.new(2, -3)
		end
	end
	
	def test_door_rejects_nil_y
		assert_raise RuntimeError do
			@@d = Door.new(2, nil)
		end
	end
	
	def test_door_rejects_negative_x_y
		assert_raise RuntimeError do
			@@d = Door.new(-3, -2);
		end
	end
	
	def test_door_rejects_nil_x_y
		assert_raise RuntimeError do
			@@d = Door.new(nil, nil);
		end
	end
	
	def test_is_open_returns_is_open
		@@d = Door.new(3, 2);
		@@d.is_open = true;
		assert_equal @@d.is_open, true;
		
		@@d.is_open = false;
		assert_equal @@d.is_open, false;
	end
end
