class Wall
	attr_accessor :x, :y, :is_seen
	
	def initialize(x, y)
		if (x.nil? || y.nil? || x < 0 || y < 0)
			raise "X, Y (#{x}, #{y}) cannot be negative or nil"
		else
			self.x = x
			self.y = y
			self.is_seen = false
		end
	end
end