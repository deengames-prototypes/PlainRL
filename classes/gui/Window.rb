# A convinient Window class for NCurses. that nimics the Curses Window class.
# You can use this as a drop-in replacement when moving from Curses to NCurses.
# It also has some added convinience functions (for colour, etc.) and it uses (x, y) instead of (y, x).
# Written by Ashiq Alibhai / ashes999@yahoo.com

require "ncurses"

# Required setup
Ncurses::initscr();
Ncurses::curs_set(0); # hide cursor
Ncurses::noecho();
Ncurses::cbreak();
Ncurses::nodelay(Ncurses::stdscr, TRUE);

Ncurses::start_color();

Ncurses::init_pair(1, Ncurses::COLOR_BLACK, Ncurses::COLOR_BLACK);
Ncurses::init_pair(2, Ncurses::COLOR_WHITE, Ncurses::COLOR_BLACK);
Ncurses::init_pair(3, Ncurses::COLOR_RED, Ncurses::COLOR_BLACK);
Ncurses::init_pair(4, Ncurses::COLOR_YELLOW, Ncurses::COLOR_BLACK);
Ncurses::init_pair(5, Ncurses::COLOR_GREEN, Ncurses::COLOR_BLACK);
Ncurses::init_pair(6, Ncurses::COLOR_CYAN, Ncurses::COLOR_BLACK);
Ncurses::init_pair(7, Ncurses::COLOR_BLUE, Ncurses::COLOR_BLACK);
Ncurses::init_pair(8, Ncurses::COLOR_MAGENTA, Ncurses::COLOR_BLACK);

# For backward-compatibility with curses; can use these anywhere.
A_BOLD = Ncurses::A_BOLD
COLOR_BLACK = Ncurses::COLOR_BLACK
COLOR_WHITE = Ncurses::COLOR_WHITE
COLOR_RED = Ncurses::COLOR_RED
COLOR_YELLOW = Ncurses::COLOR_YELLOW
COLOR_GREEN = Ncurses::COLOR_GREEN
COLOR_CYAN = Ncurses::COLOR_CYAN
COLOR_BLUE = Ncurses::COLOR_BLUE
COLOR_MAGENTA = Ncurses::COLOR_MAGENTA

class Window

	@win = nil
	
	def initialize(width, height, x, y)
		@win = Ncurses.newwin(height, width, y, x)
	end
	
	def addch(char)
		Ncurses.waddch(@win, char)
	end
	
	def addstr(message)
		Ncurses.waddstr(@win, message)
	end
	
	def attroff(attribute)
		Ncurses.wattroff(@win, attribute)
	end
	
	def attron(attribute)
		Ncurses.wattron(@win, attribute)
	end
	
	def box(a = 0, b = 0)
		Ncurses.box(@win, a, b)
	end
	
	def clear
		Ncurses.wclear(@win)
	end
	
	def close
		Ncurses.delwin(@win)
	end
	
	def curx
		begin
			Ncurses.getcurx(@win)
		rescue NoMethodError => e # win32
			x = []
			y = []
			Ncurses.getyx(@win, y, x)
			return x[0]
		end
	end
	
	def cury
		begin
			Ncurses.getcury(@win)
		rescue NoMethodError => e # win32
			x = []
			y = []
			Ncurses.getyx(@win, y, x)
			return y[0]
		end
	end
	
	def maxx
		begin
			Ncurses.getmaxx(@win)
		rescue NoMethodError => e # win32
			x = []
			y = []
			Ncurses.getmaxyx(@win, y, x)
			return x[0]
		end
	end
	
	def maxy
		begin
			Ncurses.getmaxy(@win)
		rescue NoMethodError => e # win32
			x = []
			y = []
			Ncurses.getmaxyx(@win, y, x)
			return y[0]
		end
	end
	
	def move_cursor(x, y)
		Ncurses.wmove(@win, y, x)
	end
	
	def refresh
		Ncurses.wrefresh(@win)
	end
	
	# For backward compatibility with curses
	def setpos(y, x)
		move_cursor(x, y)
	end
	
	def color_set(c)
		case c
			when COLOR_BLUE
				use_blue
			when COLOR_RED
				use_red
			when COLOR_BLACK
				use_black
			when COLOR_WHITE
				use_white
			when COLOR_GREEN
				use_green
			when COLOR_YELLOW
				use_yellow
			when COLOR_CYAN
				use_cyan
			when COLOR_MAGENTA
				use_magenta
		end
	end
	# end backward compatibility

	# my own initiative. Three sets of functions:
	# 1. Set the color (regardless of bright/dark)
	# 2. Set bright/dark (regardless of colour)
	# 3. Set the colour and bright/dark
	def use_blue
	Ncurses.wattron(@win, Ncurses::COLOR_PAIR(7))
	end
	
	def use_red
		Ncurses.wattron(@win, Ncurses::COLOR_PAIR(3))
	end
	
	def use_green
		Ncurses.wattron(@win, Ncurses::COLOR_PAIR(5))
	end
	
	def use_yellow
		Ncurses.wattron(@win, Ncurses::COLOR_PAIR(4))
	end
	
	def use_magenta
		Ncurses.wattron(@win, Ncurses::COLOR_PAIR(8))
	end
	
	def use_cyan
		Ncurses.wattron(@win, Ncurses::COLOR_PAIR(6))
	end
	
	def use_black
		Ncurses.wattron(@win, Ncurses::COLOR_PAIR(1)) # black
	end
	
	def use_bright_colours
		Ncurses.wattron(@win, Ncurses::A_BOLD)
	end
	
	def use_dark_colours
		Ncurses.wattroff(@win, Ncurses::A_BOLD)
	end
	
	def use_white
		use_bright_colours
		Ncurses.wattron(@win, Ncurses::COLOR_PAIR(2)) # white
	end
	
	def use_grey
		use_dark_colours
		Ncurses.wattron(@win, Ncurses::COLOR_PAIR(2)) # white
	end
	
	def use_bright_blue
		use_bright_colours
		use_blue
	end
	
	def use_dark_blue
		use_dark_colours
		use_blue
	end
	
	def use_bright_red
		use_bright_colours
		use_red
	end
	
	def use_dark_red
		use_dark_colours
		use_red
	end
	
	def use_bright_green
		use_bright_coloiurs
		use_green
	end
	
	def use_dark_green
		use_dark_colours
		use_green
	end
	
	def use_bright_yellow
		use_bright_colours
		use_yellow
	end
	
	def use_dark_yellow
		use_dark_colours
		use_yellow
	end
	
	def use_bright_magenta
		use_bright_colours
		use_magenta
	end
	
	def use_dark_magenta
		use_dark_colours
		use_magenta
	end
	
	def use_bright_cyan
		use_bright_colours
		use_cyan
	end
	
	def use_dark_cyan
		use_dark_colours
		use_cyan
	end
	
	
end