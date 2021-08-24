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
	printf "\section{%s}\n%s\n" "$title" "$body" > "$filename.tex"
	printf "\include{%s}\n" "$filename.tex" >> output.tex
}

main () {
	if [ "$#" -ne 1 ]; then
		echo "texscrape <filename>"
	fi

	printf "\documentclass[12pt]{article}\n%bbegin{document}\n" "\\" > output.tex

	while read -r line; do
		process_url "$line"
	done < $1

	printf "%bend{document}" "\\" >> output.tex
}	

main $1
