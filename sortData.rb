files = ["data/adjectives.dat", "data/armour.dat", "data/armour_adjectives.dat", "data/creatures.dat", "data/items.dat", "data/weapons.dat"]

files.each do |filename|
	f = File.open(filename, "r")
	data = []
	f.each do |line|
		data << line
	end
	
	data.sort!
	f.close
	f = File.open(filename, "w")
	data.each do |line|
		f.puts line
	end
	f.close
	
	puts "Sorted #{filename}"
end
