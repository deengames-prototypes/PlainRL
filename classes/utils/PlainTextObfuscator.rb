# NOT an encryption class. Obfuscates data.
class PlainTextObfuscator
	def self.obfuscate(string)
		to_return = ""
		string.each_byte do |b|
			to_return += (b + 32).chr
		end
		to_return
	end

	def self.deobfuscate(string)
		to_return = ""
		string.each_byte do |b|
			to_return += (b - 32).chr
		end
		to_return
	end
end