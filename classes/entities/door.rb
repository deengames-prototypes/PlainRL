class Door
	attr_accessor :x, :y, :is_open, :is_seen
	
	@@open_symbol = "/"
	@@close_symbol = "+"
	
	def self.close_symbol
		@@close_symbol
	end
	
	def self.open_symbol
		@@open_symbol
	end
	
	def initialize(x, y)
		if x.nil? || y.nil? || x < 0 || y < 0
			raise "X, Y (#{x}, #{y}) cannot be negative or nil"
		else
			self.x = x
			self.y = y
			self.is_open = false
			self.is_seen = false;
		end
	end
	
	def is_open?
		return self.is_open == true
	end
end