on run {input, parameters}
	set the_path to ""
	if (count of input) > 0 then
		set the_path to POSIX path of input
	end if
	set cmd to "/usr/local/bin/vim " & the_path
	
	tell application "System Events"
		set runs to false
		try
			set p to application process "iTerm"
			set runs to true
		end try
	end tell
	
	tell application "iTerm"
		activate
		
		if (count of terminals) = 0 then
			set term to (make new terminal)
		else
			set term to current terminal
		end if
		
		tell term
			set sess to (make new session at the end of sessions)
			tell sess
				exec command cmd
			end tell
			if not runs then
				terminate first session
			end if
		end tell
	end tell
end run
