require 'test/unit'

require "unit/entities/PlayerTest"
require "unit/entities/WallTest"
require "unit/entities/StairsTest"
require "unit/entities/DoorTest"
require "unit/entities/DungeonTest"
require "unit/entities/MonsterTest"
require "unit/entities/BeingTest"

class Entities < Test::Unit::TestSuite
	def self.suite
		result = Test::Unit::TestSuite.new("entities_tests")
		result << PlayerTest.suite
		result << WallTest.suite
		result << StairsTest.suite
		result << DoorTest.suite
		result << DungeonTest.suite
		result << MonsterTest.suite
		result << BeingTest.suite
		return result
	end
end