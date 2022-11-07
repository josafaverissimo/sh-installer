#!/usr/bin/env bash

BAT_GITHUB_URL="https://github.com/sharkdp/bat"
LAST_VERSION="$(curl $BAT_GITHUB_URL 2>/dev/null \
	| rg '<a [a-zA-Z =#"-]*href="[a-zA-Z/]*/releases/tag/' \
	| rg -o '(v[0-9]+\.[0-9]+\.[0-9]+)' \
)"
BAT_FILES_URL="https://github.com/sharkdp/bat/releases/expanded_assets/$LAST_VERSION"

curl -o .temp $BAT_FILES_URL 2>/dev/null
tr -d "\n" < .temp > .temp.temp && mv .temp.temp .temp
sed -i -r "s/ +/ /g;s/^ | $//g" .temp
BAT_FILES_HTML="$(cat .temp)"
rm .temp


FILES_TAGS_REGEX="$(cat <<- EOF
	(?x)
	<a[a-zA-Z0-9 /.="-]* #get all links

	class="Truncate"> #filter links by class Truncate

	[a-zA-Z0-9 <>="/.-]*</span> #get first span element from link
EOF
)"
FILES_NAMES="$(cat <<- EOF
	(?x)
	(?<=>)
		[a-zA-Z0-9 .()-]{2,} #get contents between > and <
	(?=<)
EOF
)"

FILES="$(pcre2grep -o "$FILES_TAGS_REGEX" <<< "$BAT_FILES_HTML" \
	| pcre2grep -o "$FILES_NAMES" \
	| tr ' ' ':'
)"
FILES="$(sed -r 's/ /" "/g;s/^|$/"/g' <<< $FILES)"

eval "FILES_ARRAY=($FILES)"

COUNTER=1
for file in ${FILES_ARRAY[@]}; do
	echo "${COUNTER}> $file"
	((COUNTER++))
done

