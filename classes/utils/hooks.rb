class Hooks
	@@startup = []
	@@shutdown = []
	
	def self.run_shutdown
		@@shutdown.each do |h|
			eval h
		end
	end
	
	def self.run_startup
		@@startup.each do |h|
			eval h
		end
	end
	
	def self.add_startup(h)
		@@startup << h
	end
	
	def self.add_shutdown(h)
		@@shutdown << h
	end
end