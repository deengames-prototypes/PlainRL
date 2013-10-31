class GuiHelper

	def self.write_at_center(window, y, message)
		window.setpos(y, GuiHelper.center_x_for(window, message))
		window.addstr(message)
	end
	
	def self.center_x_for(window, message)
		# 4 = padding of 2 squares
		return (window.maxx - 2 - message.length) / 2
	end
	
	def self.show_padded_message(window, message)
		# keeps buffer of 2
		words = message.split
		
		words.each do |word|
			if window.curx + word.length + 1 > window.maxx - 2 # 2 is padding, 1 is space
				window.setpos(window.cury + 1, 2)
			end
			window.addstr("#{word} ")
		end
	end
end