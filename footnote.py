import re
import sys

ref_pattern = r"\\footnote{[0-9]+}"
footnote_pattern = r"\[<a name=``f[0-9]+n''>[0-9]+<\/a>\] ((?:[^\]]|\n)*)(?=\[|\\textbf{Thanks})"

body = sys.stdin.read()
matches = re.finditer(footnote_pattern, body, re.MULTILINE)

for match in matches:
    #  print("MATCH: ", match.group(1))
    subst = r"\\footnote{" + match.group(1).strip('\n') + r"}"
    #  print("SUBST: ", subst)
    body = re.sub(ref_pattern, subst, body, 1)

    # re.sub() expands metacharacters in subst, for who knows what reason.
    body = body.replace("\t", "\\t") 
    #  print("=======================BODY_START=========================")
    #  print(body)
    #  print("=======================BODY_END=========================")

# Clear 'Notes' Section
body = re.sub(footnote_pattern, "", body, 0, re.MULTILINE)
body = re.sub(r"\\textbf{Notes}", "", body, 0, re.MULTILINE)

print(body)
