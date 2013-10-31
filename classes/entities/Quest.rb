class Quest
	attr_accessor :originator, :description, :summary, :is_complete, :name, :level
	
	@@repository = []
	
	def self.repository
		@@repository
	end
	
	def initialize(name, level, summary, description, originator)
		self.name = name
		self.description = description
		self.summary = summary
		self.originator = originator
		self.level = level
		self.is_complete = false
	end
	
	def to_s
		"{Q:#{self.name}}"
	end
end