#/usr/bin/env bash

sanitize () {
	echo $@ |
		sed "s|\#|\\\#|g" | 
		sed "s/\_/\\\_/g" |
		sed "s/\&/\\\&/g" |
		sed "s/\"\([^\"]*\)\"/\`\`\1''/g" # Correct double quotes
} 

format () {
	echo $@ |
		sed 's|<br><br><br>|\n\\vspace{\\baselineskip}\n|g' |    # Large line breaks
		sed "s|<br>|\n|g" |      						# Line breaks
		sed 's|<i>\([^<]*\)</i>|\\textit{\1}|g' | 		# Italics
		sed 's|<b>\([^<]*\)</b>|\\textbf{\1}|g' | 		# Bold 
		sed 's|<blockquote>\([^<]*\)<\/blockquote>|\\begin{quote}\1\\end{quote}|g'
}

run_custom () {
	printf '%s\n' "$*" | sed -f "$cmd_file"
}

process_url () {
	output=$(curl -s $1)
	title=$(echo $output | egrep -o "<title>(.*)<\/title>" | sed "s/<[^>]*>//g")
	body=$(echo $output |
		grep -Pazo "(?s)<body(.*)<\/body>" |
		sed "s|<body[^>]*>||g" |
		sed "s|<\/body>||g")
	body=$(sanitize "$body")
	body=$(format "$body")

	body=$(run_custom "$body")

	filename=$(echo $title | sed "s/ /-/g")
	printf "%bchapter{%s}\n%s\n" '\\' "$title" "$body" > "$2/chapters/$filename.tex"
	printf "\include{chapters/%s}\n" "$filename.tex" >> "$2/output.tex"
}

main () {
	mkdir -p "$2/chapters"
	printf '\documentclass[12pt]{book}\n\usepackage{parskip}\n\\begin{document}\n' > "$2/output.tex"
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
