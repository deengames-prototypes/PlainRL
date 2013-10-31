class LoaderSaver

	require 'yaml'
	require "classes/utils/PlainTextObfuscator"

	def self.get_games
		basedir = "saves"
		games = Dir.new(basedir).entries
		games.delete_if {|n| n == "." || n == ".." || n == ".svn" } 
		return games
	end

	def self.game_exists?(keys)
		return !keys.nil? && keys != "" && keys.to_i >= 0 &&  keys.to_i < get_games().length
	end
	
	def self.load_game(keys)
		load_data(get_games[keys.to_i])
	end
	
	private
	
	def self.load_data(filename)
		filename = "saves/#{filename}"
		f = File.open(filename, 'r')
		raw = f.read
		raw = PlainTextObfuscator.deobfuscate(raw)

		player_def = ""
		game_def = ""
		
		loading = "player"
		
		raw.each do |line|
			loading = "game" if line.chomp == "--- !ruby/object:Game "
			player_def = "#{player_def}#{line}" if loading == "player"
			game_def = "#{game_def}#{line}" if loading == "game"
		end
		
		p = YAML::load(player_def)
		Player.instance.set_from(p)
		
		g = YAML::load(game_def)		
		Game.instance.set_from(g)
		
		Dungeon.instance.floor_num = 1
		Dungeon.instance.generate_previous_floor
	end
	
	def self.save_data(filename)
		if !Dungeon.instance.start_time.nil?
			session_time = Time.new - Dungeon.instance.start_time 
			Player.instance.game_time += session_time.to_i
		end
		
		Game.instance.set_global("num_saves", Game.instance.get_global("num_saves") + 1)
		
		filename = "saves/#{filename}"
		f = File.open(filename, 'w')
		f.write(PlainTextObfuscator.obfuscate(YAML::dump(Player.instance)))
		f.write(PlainTextObfuscator.obfuscate(YAML::dump(Game.instance)))
		f.close
		
		Dungeon.instance.start_time = nil
	end
	
end