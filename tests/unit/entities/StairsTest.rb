require "classes/entities/Stairs"

class StairsTest < Test::Unit::TestCase

	@@s = nil

	def test_stairs_accepts_small_x_y
		assert_nothing_raised do
			@@s = Stairs.new(3, 4);
		end
	end
	
	def test_stairs_accepts_zero_x_y
		assert_nothing_raised do
			@@s = Stairs.new(0, 0);
		end
	end
	
	def test_stairs_rejects_negative_x
		assert_raise RuntimeError do
			@@s = Stairs.new(-2, 3);
		end
	end
	
	def test_stairs_rejects_negative_y
		assert_raise RuntimeError do
			@@s = Stairs.new(2, -3)
		end
	end
	
	def test_stairs_rejects_negative_x_y
		assert_raise RuntimeError do
			@@s = Stairs.new(-3, -2);
		end
	end
	
	def test_stairs_rejects_nil_x
		assert_raise RuntimeError do
			@@s = Stairs.new(nil, 3);
		end
	end
	
	def test_stairs_rejects_nil_y
		assert_raise RuntimeError do
			@@s = Stairs.new(2, nil)
		end
	end
	
	def test_stairs_rejects_nil_x_y
		assert_raise RuntimeError do
			@@s = Stairs.new(nil, nil);
		end
	end
end
