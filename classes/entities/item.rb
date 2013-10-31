class Item
	
	require "classes/utils/copier"
	
	attr_accessor :x, :y, :name, :symbol, :quantity, :identified, :is_seen
	attr_accessor :key #used for inventory
	@@items = []
	
	def self.items
		@@items
	end
	
	def initialize(name, symbol, quantity = 1, identified = false)
		self.name = name
		self.symbol = symbol
		self.quantity = quantity
		self.is_seen = true
	end
	
	def self.random_item(x, y)
		to_return = Copier.create_deep_copy(Item.items[rand(Item.items.size)])
		to_return.x = x
		to_return.y = y
		to_return
	end
	
	def identify
		self.identified = true
	end
	
	def custom_sort_order
		return "#{self.class} #{self.name}"
	end
end