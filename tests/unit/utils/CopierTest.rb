require "classes/utils/copier"
require "classes/entities/monster"

class CopierTest < Test::Unit::TestCase

	### create_deep_copy ###
	def test_two_deep_copies_are_different
		m = Monster.new("Rabite", 20, 1, 5, 1, "r");
		m1 = Copier.create_deep_copy(m);
		m2 = Copier.create_deep_copy(m);
		
		assert_not_equal m, m1
		assert_not_equal m1, m2
	end
	
	def test_copy_of_a_copy_is_different_from_original_and_copy
		m = Monster.new("Rabite", 20, 1, 5, 1, "r");
		m1 = Copier.create_deep_copy(m);
		m2 = Copier.create_deep_copy(m1);
		
		assert_not_equal m, m1
		assert_not_equal m, m2
		assert_not_equal m1, m2
	end
	
	def test_two_deep_copies_are_identical_in_values
		original = Monster.new("Rabite", 20, 1, 5, 1, "r");
		copy = Copier.create_deep_copy(original);
		assert_equal original.name, copy.name
		assert_equal original.total_health, copy.total_health
		assert_equal original.strength, copy.strength
		assert_equal original.agility, copy.agility
		assert_equal original.toughness, copy.toughness
		assert_equal original.alive, copy.alive
		assert_equal original.x, copy.x
		assert_equal original.y, copy.y
	end
end
