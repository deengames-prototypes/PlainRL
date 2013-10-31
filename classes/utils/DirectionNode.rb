class DirectionNode

	require "classes/utils/Profiler"

	attr_accessor :up, :down, :left, :right, :value, :depth, :parent
	
	@@INFINITY = 1.0 / 0
	
	@@LEFT = "left"
	@@RIGHT = "right"
	@@UP = "up"
	@@DOWN = "down"
	
	@@ALL_NODES = []
	
	def self.LEFT
		@@LEFT
	end
	
	def self.RIGHT
		@@RIGHT
	end
	
	def self.UP
		@@UP
	end
	
	def self.DOWN
		@@DOWN
	end
	
	def initialize(value, depth = 0, parent = nil)
		self.up = nil
		self.down = nil
		self.left = nil
		self.right = nil
		self.value = value
		self.depth = depth
		self.parent = parent
	end
	
	def self.get_path_for(monster, num_moves)		
		num_moves = 3
		@@ALL_NODES = []
		
		start_x = monster.x
		start_y = monster.y
		
		p = Player.instance
		
		#num_moves: if a monster agility is 100 to our 10, don't just look 3 steps ahead; look 13.
		root = recursively_travel(monster.x, monster.y, monster, 0, nil, num_moves)
		minimum_nodes = []
		minimum_nodes = find_minimum_nodes(root, minimum_nodes) # find by distance
		minimum_nodes = minimum_nodes.sort {|x,y| x.depth <=> y.depth }
		which_node = pick_node(minimum_nodes)
		path = generate_path(which_node)
		return path
	end
	
	private
	
	def self.recursively_travel(x, y, monster, depth, parent, num_moves)
		# This takes the most TIME; but not sure why. Maybe because for depth 8, 4^8 = 65536 nodes?
		# Put clause: 3 in a row that are distance me > distance parent? cancel this line of travelling.
		to_return = DirectionNode.new(distance_from(x, y, monster), depth, parent)
		
		# inorder traversal without pass-by-reference is impossible.
		@@ALL_NODES << to_return
		# Don't plan farthar ahead than what we can go
		return to_return  if depth > num_moves || to_return.value == @@INFINITY
		
		to_return.left = recursively_travel(x - 1, y, monster, depth + 1, to_return, num_moves)
		to_return.right = recursively_travel(x + 1, y, monster, depth + 1, to_return, num_moves)
		to_return.up = recursively_travel(x, y - 1, monster, depth + 1, to_return, num_moves)
		to_return.down = recursively_travel(x, y + 1, monster, depth + 1, to_return, num_moves)
		
		return to_return
	end
	
	def self.distance_from(x, y, monster)
		p = Player.instance
		
		return @@INFINITY if x < 0 || y < 0 || x >= Dungeon.instance.width || y >= Dungeon.instance.width || (!Dungeon.instance.is_clear?(x, y)	&& Dungeon.instance.get_monster(x, y) != monster && p.x != x && p.y != y) # crap out if not-clear and by other than us or the player
		
		return Math.sqrt(((x - p.x)**2) + ((y - p.y)**2))
	end
	
	def self.find_minimum_nodes(root, nodes)
		# passing by reference is impossible.
		@@ALL_NODES = @@ALL_NODES.sort {|x,y| x.value <=> y.value}
		i = 0
		min_nodes = []
		
		node = @@ALL_NODES.first
		v = node.value
		
		while (!node.nil? && node.value == v)
			min_nodes << node
			i += 1
			node = @@ALL_NODES[i]
		end
		
		return min_nodes
	end
	
	def self.pick_node(minimum_nodes)
		i = 0
		nodes = []
		
		node = minimum_nodes[i]
		d = node.depth		
		
		while (!node.nil? && node.depth == d)
			nodes << node
			i += 1
			node = minimum_nodes[i]
		end
		
		# choose randomly
		return nodes[rand(nodes.size)]
	end
	
	def self.generate_path(node)
		path = []
		
		while !node.parent.nil?
			if (node == node.parent.left)
				path << DirectionNode.LEFT
			elsif (node == node.parent.right)
				path << DirectionNode.RIGHT
			elsif (node == node.parent.up)
				path << DirectionNode.UP
			elsif (node == node.parent.down)
				path << DirectionNode.DOWN
			else
				raise "Node #{node} not direct descendant of parent #{node.parent}"
			end
			
			node = node.parent
		end
		
		return path.reverse
	end
	
	def to_s
		"Node v=#{self.value} d=#{self.depth} "
	end
end
