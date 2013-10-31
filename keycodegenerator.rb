# Use this script to generate key-codes for keys. Those keys go in keys.rb.
require "classes/utils/InputHelper"
require "classes/utils/Keys"

puts "Press any key to see the keycode."

while (true)
	c = InputHelper.read_char
	puts "You pressed: #{c}"
end