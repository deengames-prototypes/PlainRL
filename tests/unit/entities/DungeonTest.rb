require "classes/entities/Dungeon"

class DungeonTest < Test::Unit::TestCase
	
	@@d = nil
	@@iterations = 50
	
	def setup
		@@d = Dungeon.instance
		Monster.initialize_monsters
		Dungeon.floor_num = 1
	end
	
	### generate_next_floor ###
	### test only unique features, since it calls generate ###
	
	def test_generate_next_floor_increments_floor_number
		old_floor = Dungeon.floor_num
		@@d.generate_next_floor
		assert_equal Dungeon.floor_num, old_floor + 1
	end
	
	### generate ###
	
	def test_generate_generates_monsters
		@@d.generate
		assert_not_equal @@d.monsters.size, 0
	end
	
	def test_generate_generates_walls
		@@d.generate
		assert_not_equal @@d.walls.length, 0
	end
	
	def test_generate_generates_closed_doors
		@@d.generate
		assert_not_equal @@d.doors.length, 0
		@@d.doors.each do |d|
			assert_equal false, d.is_open
		end
	end
	
	def test_generate_generates_stairs
		@@d.generate
		assert_not_equal @@d.stairs.length, 0
	end
	
	def test_generate_places_player_on_empty_floor
		(1..@@iterations).each do
			@@d.generate
			p = Player.instance
			assert_equal false, @@d.is_wall?(p.x, p.y)
			assert_equal false, @@d.is_monster?(p.x, p.y)
			assert_equal false, @@d.is_closed_door?(p.x, p.y)
		end
	end
	
	def test_generate_places_monsters_on_empty_floor
		(1..@@iterations).each do
			@@d.generate
			p = Player.instance
			@@d.monsters.each do |m|
				assert_equal false, @@d.is_wall?(m.x, m.y)
				assert_equal false, @@d.is_closed_door?(m.x, m.y)
				assert_equal false, m.x == p.x && m.y == p.y
			end
		end
	end
	
	def test_generate_places_stairs_on_empty_floor
		(1..@@iterations).each do
			@@d.generate
			@@d.stairs.each do |s|
				assert_equal false, @@d.is_wall?(s.x, s.y)
				assert_equal false, @@d.is_monster?(s.x, s.y)
				assert_equal false, @@d.is_closed_door?(s.x, s.y)
			end
		end
	end
	
	def test_generate_doesnt_places_stairs_beside_doors
		(1..@@iterations).each do
			@@d.generate
			@@d.stairs.each do |s|
				@@d.doors.each do |d|
					assert_equal false, d.x == s.x && (d.y == s.y - 1 || d.y == s.y + 1)
					assert_equal false, d.y == s.y && (d.x == s.x - 1 || d.x == s.x + 1)
				end
			end
		end
	end
	
	def test_generate_doesnt_places_stairs_beside_walls
		(1..@@iterations).each do
			@@d.generate
			@@d.stairs.each do |s|
				@@d.walls.to_array.each do |w|
					assert_equal false, w.x == s.x && (w.y == s.y - 1 || w.y == s.y + 1)
					assert_equal false, w.y == s.y && (w.x == s.x - 1 || w.x == s.x + 1)
				end
			end
		end
	end
	
	def test_generate_places_doors_between_walls
		(1..@@iterations).each do
			@@d.generate
			@@d.doors.each do |d|

			# check D is not on an edge
				assert_equal true, d.x >= 0
				assert_equal true, d.x < @@d.width
				assert_equal true, d.y >= 0
				assert_equal true, d.y < @@d.height
				
				# check D is sandwiched between walls
				assert_equal true,
					(@@d.is_wall?(d.x - 1, d.y) && @@d.is_wall?(d.x + 1, d.y)) ||
					(@@d.is_wall?(d.x, d.y - 1) && @@d.is_wall?(d.x, d.y + 1))
					
				# check D is not surrounded on all sides
				assert_equal false,
					(@@d.is_wall?(d.x - 1, d.y) && @@d.is_wall?(d.x + 1, d.y)) &&
					(@@d.is_wall?(d.x, d.y - 1) && @@d.is_wall?(d.x, d.y + 1))
			end
		end
	end
	
	def test_generate_places_doors_between_walls
		(1..@@iterations).each do
			@@d.generate
			@@d.doors.each do |d|
				# check D is not on an edge
				assert_not_equal d.x, 0
				assert_not_equal d.x, @@d.width
				assert_not_equal d.y, 0
				assert_not_equal d.y, @@d.height
				
				# check D is sandwiched between walls
				assert_equal true,
					(@@d.is_wall?(d.x - 1, d.y) && @@d.is_wall?(d.x + 1, d.y)) ||
					(@@d.is_wall?(d.x, d.y - 1) && @@d.is_wall?(d.x, d.y + 1))
					
				# check D is not surrounded on all sides
				assert_equal false,
					(@@d.is_wall?(d.x - 1, d.y) && @@d.is_wall?(d.x + 1, d.y)) &&
					(@@d.is_wall?(d.x, d.y - 1) && @@d.is_wall?(d.x, d.y + 1))
			end
		end
	end
	
	def test_generate_generates_boss_on_boss_floor
		boss_floor_num = Monster.bosses.keys.first
		assert_equal true, boss_floor_num > 0
		
		boss = Monster.bosses[boss_floor_num]
		assert_not_equal boss, nil

		(1..boss_floor_num - 2).each do |i|
			@@d.generate_next_floor
		end
		
		Dungeon.floor_num += 1
		@@d.generate
		
		assert_equal Dungeon.floor_num, boss_floor_num
		assert_equal true, @@d.monsters.include?(boss)
	end
	
	def test_generate_generates_no_boss_on_non_boss_floor
		boss_floor_num = Monster.bosses.keys.first
		assert_equal true, boss_floor_num > 0
		
		boss = Monster.bosses[boss_floor_num]
		assert_not_equal boss, nil
		
		
		(1..boss_floor_num - 2).each do |i|
			Dungeon.floor_num += 1
			@@d.generate
			assert_not_equal Dungeon.floor_num, boss_floor_num
			assert_equal false, @@d.monsters.include?(boss)
		end
	
	end
end
