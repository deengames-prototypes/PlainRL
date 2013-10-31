class InputHelper
	# Reading a character is tricky.  This solution is from http://www.rubyquiz.com/quiz5.html
	# It's cross-platform; defaults to Windows, and falls-back to UNIX.
	
	# Swallow key 224, which applies to all arrow keys, eg: UP = 224 72; DOWN = 224 80; but we want to read it as ONE key.
	begin
		require "Win32API"

		def self.read_char
			r= Win32API.new("crtdll", "_getch", [], "L").Call
			if (r == 224)
				Win32API.new("crtdll", "_getch", [], "L").Call
			else
				r
			end
		end
	rescue LoadError
		def self.read_char
			system "stty raw -echo"
			r = STDIN.getc
			if (r == 224)
				STDIN.getc
			else
				r
			end
		ensure
			system "stty -raw echo"
		end
	end
	# end code from http://www.rubyquiz.com/quiz5.html
	
	def self.read_line_and_show(window, limit = 8)
		key = ""
		string = ""
		
		while (key != Keys.ENTER)
			key = InputHelper.read_char
			
			if  key == Keys.BACKSPACE && string.length > 0
				window.setpos(window.cury, window.curx - 1)
				window.addstr(" ")
				window.setpos(window.cury, window.curx)
				window.setpos(window.cury, window.curx - 1)
				window.refresh
			end
			
			if key == Keys.BACKSPACE
				if string.length > 1
					string = string[0 .. string.length - 2] 
				else
					# special case: delete string of 1 character
					string = ""
				end
			elsif string.length < limit && !key.chr.match(/[a-zA-Z0-9\-]/).nil?
				string += key.chr
				window.addch(key) 
				window.refresh
			end
		end
		
		return string
	end
end