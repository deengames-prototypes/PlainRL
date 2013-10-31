$: << File.expand_path(File.dirname("") + "../../../")

require 'test/unit'
require 'test/unit/ui/console/testrunner'

require "unit/entities/Entities"
require "unit/utils/Utils"

def all_tests_suite
    result = Test::Unit::TestSuite.new("all_tests")
    result << Entities.suite
	result << Utils.suite
    return result
end

Globals.testing = true
Logger.create

begin
	runner = Test::Unit::UI::Console::TestRunner.new(all_tests_suite)
	runner.start
rescue
	puts "What happen?! #{$!}"
end

puts "Done!"

Logger.close