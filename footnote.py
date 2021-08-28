import re
import sys
from paulutil import *

ref_pattern = r"\\footnote{[0-9]+}"
footnote_pattern = r"\[<a name=``f[0-9]+n''>[0-9]+<\/a>\] ((?:[^\]])*)(?=\[|\\textbf{Thanks})"
alternate_fn_pattern = r"\[<a name=``f[0-9]+n'' hef=``\\#f[0-9]+''>[0-9]+<\/a>\] ((?:[^\]])*)(?=\[|\\textbf{Thanks})"

body = sys.stdin.read()
matches = re.finditer(footnote_pattern, body, re.MULTILINE)

if re.search(footnote_pattern, body) == None:
    matches = re.finditer(alternate_fn_pattern, body, re.MULTILINE)

for match in matches:
    subst = r"\\footnote{" + \
            process(match.group(1)) + r"}"
    body = re.sub(ref_pattern, subst, body, 1)

# Assuming text has no real tabs
body = body.replace("\t", "\\t") 
body = unprocess(body)

# Clear 'Notes' Section
body = re.sub(footnote_pattern, "", body, 0, re.MULTILINE)
body = re.sub(alternate_fn_pattern, "", body, 0, re.MULTILINE)
body = re.sub(r"\\section\*{Notes}", "", body, 0, re.MULTILINE)

print(body)
