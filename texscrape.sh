#/usr/bin/env bash

sanitize () {
	echo $@ |
		sed "s/\#/\\\#/g" | 
		sed "s/\_/\\\_/g" |
		sed "s/\&/\\\&/g"
} 

process_url () {
	output=$(curl -s $1)
	title=$(echo $output | egrep -o "<title>(.*)<\/title>" | sed "s/<[^>]*>//g")
	body=$(echo $output |
		grep -Pazo "(?s)<body(.*)<\/body>" |
		sed "s/<body[^>]*>//g" |
		sed "s/<\/body>//g")
	body=$(sanitize "$body")
	filename=$(echo $title | sed "s/ /-/g")
	printf "\section{%s}\n%s\n" "$title" "$body" > "$2/chapters/$filename.tex"
	printf "\include{chapters/%s}\n" "$filename.tex" >> "$2/output.tex"
}

main () {
	mkdir "$2/chapters"
	printf "\documentclass[12pt]{article}\n%bbegin{document}\n" '\\' > "$2/output.tex"
	while read -r line; do
		process_url "$line" $2
	done < "$1"
	printf "%bend{document}" '\\' >> "$2/output.tex"
}	

if [ "$#" -ne 2 ]; then 
	echo "usage: texscrape <manifest> <output directory>"
	exit 1
fi


if [ ! -d "$2" ]; then
	echo "Error: Unable to find output directory \"$2\""
	exit 1 
fi

main $@
