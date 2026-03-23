#!/usr/bin/env bash

# Generates color previews of /asset/css/<color>.css as <color>.html

color_previews_dir="../color-previews/_posts"
color_previews_dir_permalink_prefix="/color-previews"
css_dir="../assets/assets/css"

rm -rf "${color_previews_dir}"
mkdir -p "${color_previews_dir}"

echo "==> Creating color preview pages in ${color_previews_dir}..."

preview_body=$(cat markdown-to-html-test.html)

date_prefix=""
minutes=1

shopt -s nullglob
for color in "${css_dir}"/*.css; do
  # Remove leading ${css_dir}/
  color=${color#*"${css_dir}"/}
  # Remove trailing .css
  color=${color%.*}

  minutes=$((minutes + 1))
  cat > "${color_previews_dir}/${date_prefix}${color}.html" << END
---
title: ${color} Preview
date: 2023-12-30 12:0${minutes}:00 +00:00
description: "A generated preview of color ${color}"
theme_color: ${color}
sitemap:
  disable: true
---
END

  echo "${preview_body}" >> "${color_previews_dir}/${date_prefix}${color}.html"
done
shopt -u nullglob

echo "==> Creating color preview pages for special case no theme in ${color_previews_dir}..."

cat > "${color_previews_dir}/${date_prefix}no-theme.html" << END
---
title: No Theme Preview
date: 2023-12-30 12:00:00 +00:00
description: "A generated preview of no theme"
permalink: ${color_previews_dir_permalink_prefix}/:title
layout: none
---
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <title>No Theme</title>
</head>
<body>
END

echo "${preview_body}" >> "${color_previews_dir}/${date_prefix}no-theme.html"

cat >> "${color_previews_dir}/${date_prefix}no-theme.html" << END
</body>
</html>
END

echo "==> Generated the following color preview pages in ${color_previews_dir}"

ls "${color_previews_dir}"
