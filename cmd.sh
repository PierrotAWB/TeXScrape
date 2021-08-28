#/usr/bin/bash env

printf "%s\n" "$*" |
	sed 's|\\&mdash;|\\textemdash\\ |g;
  		s|\\&nbsp;|~|g;
  		/^<table/d;
  		/[^-]><table/d;
  		/tr>/d;
  		/height\=[0-9]\+/d;
  		/<\/table/d;
		/<img src=/d;
		/\\textbf{Want to start a startup?}/d;
		/<a href=``http:\/\/ycombinator.com\/apply.html'"''"'>Y Combinator<\/a>/d;
		s|^\s\?\\textbf{\(.*\)}$|\\section*{\1}|g;
  		s|<font size=2 face=``verdana'"''"'>\([A-Z][a-z]\{2,8\} 20[0-9][0-9]\)|\\vspace{-2em}\\hfill\\textbf{\1}\\vspace{1em}|g;
		s|^\([A-Z][a-z]\{2,8\} 20[0-9][0-9]\)$|\\vspace{-2em}\\hfill\\textbf{\1}\\vspace{1em}|g;
		s|<font[^>]*>||g;
		s|</font[^>]*>||g;
		s| \[<a href=``\\#f[0-9]\+n'"''"'>\([0-9]\+\)</a>\]|\\footnote{\1}|g;
		s| \[<a name=``f[0-9]\+'"''"' href=``\\#f[0-9]\+n'"''"'>\([0-9]\+\)</a>\]|\\footnote{\1}|g;' |
  	python footnote.py | 
  	sed 's/\x08//g; s/\x0b//g;
		s|\\textbf{Thanks}|\\par\\noindent\\rule{\\textwidth}{0.4pt}\n\n&|g;' |
	python href.py

