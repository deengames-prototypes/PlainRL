class Stairs
	attr_accessor :is_up, :is_seen
	
	require "classes/modules/VisibleObject"
	include VisibleObject
	
	@@up_symbol = "<"
	@@down_symbol = ">"
	
	def self.up_symbol
		@@up_symbol
	end
	
	def self.down_symbol
		@@down_symbol
	end
	
	def initialize(x, y, is_up = false)
		if (x.nil? || y.nil? || x < 0 || y < 0)
			raise "X, Y (#{x}, #{y}) cannot be negative or nil"
		else
			self.x = x
			self.y = y
			self.is_up = is_up;
			self.is_seen = false;
			self.visible = true
		end
	end
end