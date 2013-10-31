class Profiler

	@@watching = {}
	@@log = []
	@@FILENAME = "profile.txt"
	
	def self.start(message)
		@@watching[message] = Time.now
	end
	
	def self.stop(message)
		now = Time.now
		raise("Didn't start for #{message}!") if @@watching[message].nil?
		elapsed = now - @@watching[message]
		@@log << "#{message}: #{elapsed}s"
	end
	
	def self.dump_log
		f = File.open(@@FILENAME, "w")
		@@log.each do |message|
			f.write("#{message}\n")
		end
		f.close
	end
end