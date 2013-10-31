require "classes/entities/Wall"

class WallTest < Test::Unit::TestCase

	@@w = nil

	def test_wall_accepts_small_x_y
		assert_nothing_raised do
			@@w = Wall.new(3, 4);
		end
	end
	
	def test_wall_accepts_zero_x_y
		assert_nothing_raised do
			@@w = Wall.new(0, 0);
		end
	end
	
	def test_wall_rejects_negative_x
		assert_raise RuntimeError do
			@@w = Wall.new(-2, 3);
		end
	end
	
	def test_wall_rejects_negative_y
		assert_raise RuntimeError do
			@@w = Wall.new(2, -3)
		end
	end
	
	def test_wall_rejects_negative_x_y
		assert_raise RuntimeError do
			@@w = Wall.new(-3, -2);
		end
	end
	
	def test_wall_rejects_nil_x
		assert_raise RuntimeError do
			@@w = Wall.new(nil, 3);
		end
	end
	
	def test_wall_rejects_nil_y
		assert_raise RuntimeError do
			@@w = Wall.new(2, nil)
		end
	end
	
	def test_wall_rejects_negative_x_y
		assert_raise RuntimeError do
			@@w = Wall.new(nil, nil);
		end
	end
end
