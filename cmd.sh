#/usr/bin/bash env

printf "%s\n" "$*" |
	sed 's|\\&mdash;|\\textemdash\\ |g;
  		s|\\&nbsp;|~|g;
  		/<table/d;
  		/<\/table/d;
  		s|<font size=2 face=``verdana'"''"'>\(.*\)|\\vspace{-2em}\\hfill\\textbf{\1}\\vspace{1em}|g;
		s|<font[^>]*>||g;
		s|</font[^>]*>||g;
		s| \[<a href=``\\#f[0-9]\+n'"''"'>\([0-9]\+\)</a>\]|\\footnote{\1}|g;' |
  	python footnote.py | 
  	sed 's/\x08//g; s/\x0b//g;
		s|\\textbf{Thanks}|\\par\\noindent\\rule{\\textwidth}{0.4pt}\n\n&|g'
			
	
