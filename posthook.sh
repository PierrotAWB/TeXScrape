#!/usr/bin/env bash

OUTPUT="output/chapters/"

# Use of [^$] is for idempotence.

sed -i 's/[^$]n^2/\$&\$/' "$OUTPUT"'Undergraduation.tex'
sed -i 's|[^$]1/n^2|\$&\$|' "$OUTPUT"'Why-to-Not-Not-Start-a-Startup.tex'
sed -i 's_[^$]wd^m - k|w - d|^n_\$&\$_;
        s|\(w\)\( is will and \)\(d\)\( discipline\)|\$\1\$\2\$\3\$\4|' \
	"$OUTPUT"'The-Anatomy-of-Determination.tex'
sed -i 's|[^$]10^6|\$&\$|' "$OUTPUT"'The-New-Funding-Landscape.tex'
sed -i 's|^ }\$\\longrightarrow\$$||' "$OUTPUT"'The-Founder-Visa.tex'
sed -i 's|\&\#8776;|\$\approx\$|; s/[^$]1.05 ^ 15/\$&\$/' "$OUTPUT""Why-It's-Safe-for-Founders-to-Be-Nice.tex"
sed -i 's|[^$].99^60|\$&\$|' "$OUTPUT""Modeling-a-Wealth-Tax.tex"
