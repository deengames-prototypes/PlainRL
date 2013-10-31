require "classes/utils/extendedMath"

class ExtendedMathTest < Test::Unit::TestCase


	### max ###
	
	def test_max_with_a_equals_b_returns_a
		assert_equal 7, ExtendedMath.max(7, 7)
	end
	
	def test_max_with_a_less_than_b_returns_b
		assert_equal 7, ExtendedMath.max(3, 7)
	end
	
	def test_max_with_b_less_than_a_returns_a
		assert_equal 3, ExtendedMath.max(1, 3)
	end
	
	def test_max_with_a_zero_returns_non_zero
		assert_equal 1, ExtendedMath.max(1, 0)
	end
	
	def test_max_with_negative_and_positive_returns_positive
		assert_equal 1, ExtendedMath.max(-3, 1)
	end
	
	def test_max_with_two_negatives_returns_smaller_negative
		assert_equal -1, ExtendedMath.max(-1, -3)
	end
	
	def test_max_with_two_zeros_returns_zero
		assert_equal 0, ExtendedMath.max(0, 0)
	end
	
	### min ###
	
	def test_min_with_a_equals_b_returns_a
		assert_equal 7, ExtendedMath.min(7, 7)
	end
	
	def test_min_with_a_less_than_b_returns_a
		assert_equal 3, ExtendedMath.min(3, 7)
	end
	
	def test_min_with_b_less_than_a_returns_a
		assert_equal 1, ExtendedMath.min(1, 3)
	end
	
	def test_min_with_a_zero_returns_zero
		assert_equal 0, ExtendedMath.min(1, 0)
	end
	
	def test_min_with_negative_and_positive_returns_negative
		assert_equal -3, ExtendedMath.min(-3, 1)
	end
	
	def test_min_with_two_negatives_returns_bigger_negative
		assert_equal -3, ExtendedMath.min(-1, -3)
	end
	
	def test_min_with_two_zeros_returns_zero
		assert_equal 0, ExtendedMath.min(0, 0)
	end
end
