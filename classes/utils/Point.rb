class Point
	attr_accessor :x, :y, :is_occluded
	
	def initialize(x, y, is_occluded = false)
		self.x = x
		self.y = y
		self.is_occluded = is_occluded
	end

	# Doesn't seem to work
	def self.uniq(array)
		unique = []
		array.each do |a|
			found = false
			unique.each do |u|
				found = true if a.eql?(u)
			end
			if found == false
				unique << a
			end
		end
	
		return unique
	end
	
	def to_s
		return "(#{self.x}, #{self.y})"
	end
	
	def eql?(target)
		return false if !target.is_a?(Point)
		return target.x == self.x && target.y == self.y
	end
end