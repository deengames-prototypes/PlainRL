class XYIndexedCollection
	
	attr_accessor :data
	
	def initialize
		self.data = {}
	end
	
	def add(o)
		self.data[get_key_from(o)] = o
	end
	
	def add_at(x, y, o)
		self.data[get_key(x, y)] = o
	end
	
	def clear
		self.data = {}
	end
	
	def length
		self.data.length
	end
	
	def delete(o)
		delete_at(o.x, o.y)
	end
	
	def delete_at(x, y)
		if (x.nil? || y.nil? || x < 0 || y < 0)
			raise "X, Y (#{x}, #{y}) cannot be nil or negative."
		else
			self.data.delete(get_key(x, y))
		end
	end
	
	def is_at?(x, y)
		if (x.nil? || y.nil? || x < 0 || y < 0)
			raise "X, Y (#{x}, #{y}) cannot be nil or negative."
		else
			!self.data[get_key(x, y)].nil?
		end
	end
	
	def get(x, y)
		self.data[get_key(x, y)]
	end
	
	def to_array
		to_return = []
		self.data.keys.each do |k|
			to_return << self.data[k]
		end
		to_return
	end
	
	def length
		return self.data.length
	end
	
	private
	
	def get_key_from(o)
		begin
			get_key(o.x, o.y)
		rescue NoMethodError => n
			raise "#{o} doesn't have an X and Y!"
		end
	end
	
	def get_key(x, y)
		"#{x}, #{y}"
	end
end