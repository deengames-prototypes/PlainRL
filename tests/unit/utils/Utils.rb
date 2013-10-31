require 'test/unit'

require "unit/utils/CopierTest"
require "unit/utils/ExtendedMathTest"
require "unit/utils/HooksTest"
require "unit/utils/InputHelperTest"
require "unit/utils/LoggerTest"
require "unit/utils/XYIndexedCollectionTest"

class Utils < Test::Unit::TestSuite
	def self.suite
		result = Test::Unit::TestSuite.new("utils_tests")
		result << CopierTest.suite
		result << ExtendedMathTest.suite
		result << HooksTest.suite
		result << InputHelperTest.suite
		result << LoggerTest.suite
		result << XYIndexedCollectionTest.suite
		return result
	end
end