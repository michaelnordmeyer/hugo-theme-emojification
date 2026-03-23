#!/usr/bin/env sh

# These can report more than the front matter variables

echo "==> Themes"
find . -type f -exec grep -Eo '.Params.[^\ \}\)`"]+' {} \; | sort | uniq

echo "==> Markdown content with YAML front matter"
find content -type f -iname "*.md" -exec grep -Eo '^[ ]+[a-zA-Z]+:' {} \; | sort | uniq

echo "==> Markdown content with TOML front matter having a multiple of two space indentation and one space around the equal sign"
find content -type f -iname "*.md" -exec grep -Eo '^([ ][ ])+[a-zA-Z]+ = ' {} \; | sort | uniq
