if $TERM == "xterm"
    set t_Co=256
endif

let solarized=system("head -n 1 $HOME/.solarized")
if $SOLARIZED == "light"
    set background=light
elseif $SOLARIZED == "dark"
    set background=dark
elseif solarized == "dark\n"
    set background=dark
elseif solarized == "light\n"
    set background=light
elseif has('gui_running')
    set background=light
else
    set background=dark
endif

colorscheme solarized
