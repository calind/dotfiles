set guioptions-=m  " no menu
set guioptions-=T  " no toolbar

if has("gui_running")
    cnoreabbrev q close
    cnoreabbrev wq w<bar>close
endif


