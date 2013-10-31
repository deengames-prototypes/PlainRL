require "classes/utils/XYIndexedCollection"
require "classes/entities/Wall"

class XYIndexedCollectionTest < Test::Unit::TestCase

	@@x = nil
	@@dummy = Wall.new(2, 1)

	def setup
		@@x = XYIndexedCollection.new
	end
	
	### initialize ###
	
	def test_initialize_clears_data
		assert_equal 0, @@x.data.length
		@@x.add(@@dummy)
		@@x = XYIndexedCollection.new
		assert_equal 0, @@x.data.length
	end

	### add ###
	
	def test_add_adds_object_with_x_y
		@@x.add(@@dummy)
		assert_equal 1, @@x.data.length
		@@x.add(Wall.new(6, 3))
		assert_equal 2, @@x.data.length
	end
	
	def test_add_raises_error_with_nil
		assert_raise RuntimeError do
			@@x.add(nil)
		end
	end
	
	def test_add_raises_error_with_non_x_y_object
		assert_raise RuntimeError do
			@@x.add(Object.new)
		end
	end
	
	### clear ###
	def test_clear_clears_data
		@@x.add(Wall.new(0, 0))
		@@x.clear
		assert_equal 0, @@x.data.length
	end
	
	def test_clear_doesnt_raise_error_if_no_data
		@@x.add(Wall.new(3, 3))
		assert_nothing_raised do
			@@x.clear
			@@x.clear
		end
	end
	
	### length ###
	
	def test_length_returns_data_length
		@@x.clear
		assert_equal 0, @@x.length
		@@x.add(Wall.new(2, 3))
		assert_equal 1, @@x.length
		@@x.add(Wall.new(3, 3))
		assert_equal 2, @@x.length
		@@x.clear
		assert_equal 0, @@x.length
		@@x.add(Wall.new(1, 7))
		assert_equal 1, @@x.length
	end
	
	### delete_at ###
	def test_delete_at_deletes_existing_item
		@@x.add(Wall.new(2, 3))
		assert_equal 1, @@x.length
		@@x.delete_at(2, 3)
		assert_equal 0, @@x.length
	end
	
	def test_delete_at_does_nothing_for_non_existant_item
		@@x.add(Wall.new(7, 6))
		assert_equal 1, @@x.length
		assert_nothing_raised do
			@@x.delete_at(7, 8)
			assert_equal 1, @@x.length
		end
	end
	
	def test_delete_at_raises_exception_for_nil_x_or_y
		@@x.add(Wall.new(7, 6))
		assert_equal 1, @@x.length
		assert_raise RuntimeError do
			@@x.delete_at(nil, 6)
		end
		assert_raise RuntimeError do
			@@x.delete_at(2, nil)
		end
		assert_raise RuntimeError do
			@@x.delete_at(nil, nil)
		end
	end
	
	def test_delete_at_raises_exception_for_negative_x_or_y
		@@x.add(Wall.new(7, 6))
		assert_equal 1, @@x.length
		assert_raise RuntimeError do
			@@x.delete_at(-2, 6)
		end
		assert_raise RuntimeError do
			@@x.delete_at(2, -6)
		end
		assert_raise RuntimeError do
			@@x.delete_at(-2, -6)
		end
	end
	
	### is_at? ###
	def test_is_at_returns_true_for_existing_item
		@@x.add(Wall.new(2, 3))
		assert_equal 1, @@x.length
		assert_equal true, @@x.is_at?(2, 3)
	end
	
	def test_is_at_returns_false_for_non_existant_item
		@@x.add(Wall.new(2, 3))
		assert_equal 1, @@x.length
		assert_equal false, @@x.is_at?(2, 6)
	end
	
	def test_is_at_raises_exception_for_nil_x_or_y
		@@x.add(Wall.new(2, 3))
		assert_equal 1, @@x.length
		assert_raises RuntimeError do
			@@x.is_at?(nil, 3)
		end
		assert_raises RuntimeError do
			@@x.is_at?(2, nil)
		end
		assert_raises RuntimeError do
			@@x.is_at?(nil, nil)
		end
	end
	
	def test_is_at_raises_exception_for_negative_x_or_y
		@@x.add(Wall.new(2, 3))
		assert_equal 1, @@x.length
		assert_raises RuntimeError do
			@@x.is_at?(-2, 3)
		end
		assert_raises RuntimeError do
			@@x.is_at?(2, -3)
		end
		assert_raises RuntimeError do
			@@x.is_at?(-2, -3)
		end
	end
	
	### to_array ###
	def test_to_array_returns_proper_array
		a = [Wall.new(2, 3), Wall.new(7, 13), Wall.new(64, 28), Wall.new(25, 20)]
		(0 .. a.length - 1).each do |i|
			@@x.add(a[i])
		end
		
		# check equality by value
		expected = @@x.to_array
		assert_equal a.length, expected.length
		
		a.each do |x|
			assert_equal true, expected.include?(x)
		end
	end
end
