class Logger
	
	@@FILENAME = "log.txt"
	
	def self.create
		# truncate: create new file
		file = File.open(@@FILENAME, 'w')
		Logger.log("Log file created at #{Time.new}");
	end
	
	def self.log(message)
		Logger.log_message(message + "\n")
	end
	
	def self.log_message(message)
		f = open_for_append	
		f.write(message)
		f.close
	end
	
	private
	
	def self.open_for_append
		return File.open(@@FILENAME, 'a')
	end
end