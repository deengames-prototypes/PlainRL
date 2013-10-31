class Room
	attr_accessor :x, :y, :width, :height
	
	def initialize(x, y, width, height)
		self.x = x
		self.y = y
		self.width = width
		self.height = height
	end
end