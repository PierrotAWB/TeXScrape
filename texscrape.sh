#/usr/bin/env bash

sanitize () {
	printf "%s\n" "$*" |
		sed "s|\#|\\\#|g;
		     s/\_/\\\_/g
			 s/\&/\\\&/g;
			 "'s/\$/\\\$/g;'"
			 s/%/\\\%/g;
			 s/<p>//g;
			 s|</p>||g;
			 s/<!--/\$"'\\'"longleftarrow\${"'\\'"em Comment: /g; # breaks on multi-line comments
			 s|-->|}\$"'\\'"longrightarrow\$|g;
			 s/\"\([^\"]*\)\"/\`\`\1''/g" # Correct double quotes
} 

format () {
	printf "%s\n" "$*" |
		sed "s|<br>|\n|g;       						# Line break
			s|<i>\([^<]*\)</i>|"'\\'"textit{\1}|g;  	# In-line Italics
			s|<b>\([^<]*\)</b>|"'\\'"textbf{\1}|g;  	# In-line Bold 
			s|<tt>\([^<]*\)</tt>|"'\\'"texttt{\1}|g;  	
			s|<i>|{"'\\'"em |g;  				# Multi-line Italics
			s|</i>|}|g;  				
			s|<xmp>|"'\\'"begin{verbatim}|g;  	
			s|</xmp>|"'\\'"end{verbatim}|g;  	
			s|<u>\([^<]*\)</u>|\1|g; 	 				# Underline 
		    s|<ul>|"'\\'"begin{itemize}|g;
		    s|</ul>|"'\\'"end{itemize}|g;
		    s|<ol>|"'\\'"begin{enumerate}|g;
		    s|</ol>|"'\\'"end{enumerate}|g;
		    s|<li>|"'\\'"item|g;
		    s|<li>|"'\\'"item|g;
			s|<blockquote>|"'\\'"begin{quote}|g;
			s|<\/blockquote>|"'\\'"end{quote}|g"
}

run_custom () {
	printf '%s\n' "$*" | "./$cmd_file"
}

process_url () {
	output=$(curl -s $1)
	title=$(echo $output | egrep -o "<title>(.*)<\/title>" | sed "s/<[^>]*>//g; s|%|-percent|g")
	
	body=$(printf "%s\n" "$output" |
		grep -Pazo "(?s)<body(.*)<\/body>" | tr '\0' '\n' |
		sed "s|<body[^>]*>||g; s|<\/body>||g")
	body=$(sanitize "$body")
	body=$(format "$body")
	body=$(./"$cmd_file" "$body")

	filename=$(echo $title | sed "s/ /-/g; s|/|-|g;")
	printf "%bchapter{%s}\n%s\n" '\\' "$title" "$body" > "$2/chapters/$filename.tex"
	printf "\include{chapters/%s}\n" "$filename.tex" >> "$2/output.tex"
	printf "Done $curr_line of $total_lines (%.2f%%)\r" "$((10000 * $curr_line /
	$total_lines))e-2"
	let "curr_line+=1"
}

main () {
	mkdir -p "$2/chapters"
	
	# Minimal Preamble
	printf '\documentclass[12pt]{book}\n\\usepackage{parskip, hyperref}\n\\begin{document}\n' > "$2/output.tex"
	total_lines=$(wc -l $1 | awk '{print $1}')
	curr_line=1
	if [ "$#" -eq 3 ]; then
		while read -r line; do
			process_url "$line" $2 $3
		done < "$1"
	else
		while read -r line; do
			process_url "$line" $2
		done < "$1"
	fi

	printf '\\end{document}' >> "$2/output.tex"
}	

case "$#" in
	2) true ;;
	3) if [ ! -f "$3" ]; then 
			echo "Error: Unable to find command file \"$3\"" && exit 1
	   fi
	   cmd_file="$3" ;;
	*) echo "usage: texscrape <manifest> <output directory> [command file]" &&
		exit 1 ;;
esac

if [ ! -d "$2" ]; then
	echo "Error: Unable to find output directory \"$2\""
	exit 1 
fi

main $@
