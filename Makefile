SHELL=/usr/bin/env bash

current_date := $(shell date +%Y-%m-%d-%H-%M-%S)

## Build settings
content_dir = exampleSite/$(shell hugo config --source exampleSite/ --format yaml | yq '.contentdir' | tr -d '\n')
output_dir = exampleSite/$(shell hugo config --source exampleSite/ --format yaml | yq '.publishdir' | tr -d '\n')
# -c 8- for insecure HTTP URLs
base_url = $(shell baseurl=$$(hugo config --source exampleSite/ --format yaml | yq '.baseurl' | cut -c 9- | tr -d '\n'); printf "$${baseurl:0: -1}")

## Deployment settings
ssh_host = michaelnordmeyer.com
ssh_port = 1111
ssh_user = root
ssh_path = "/srv/http/${base_url}/"

.PHONY: help
help:
	@perl -nle'print $& if m{^[a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-14s\033[0m %s\n", $$1, $$2}'

.PHONY: build
build: actualbuild beautify ## Builds the artifact

.PHONY: buildwithmetrics
buildwithmetrics: ## Builds the artifact
	$(info ==> Building ${base_url} with metrics...)
	@hugo --source exampleSite/ --logLevel info --templateMetrics --templateMetricsHints
# 	@hugo --source exampleSite/ --logLevel info --printUnusedTemplates --templateMetrics --templateMetricsHints

.PHONY: actualbuild
actualbuild: icons ## Actual build step. Use `build` instead
	$(info ==> Building ${base_url}...)
	@time (hugo --source exampleSite/)
	@rm -rf "${output_dir}/posts/index.html"
	@rm -rf "${output_dir}/errors/index.html"
	@rm -rf "${output_dir}"/tags/**/feed.xml

.PHONY: robots
robots: ## Builds robots.txt
	$(info ==> Building ${base_url} robots.txt...)
	@cat ../robots.txt >> exampleSite/static/robots.txt

.PHONY: icons
icons: ## Builds favicons
	$(info ==> Building ${base_url} icons...)
	@time (_tools/generate-icons.sh . $$(hugo config --source exampleSite/ --format yaml | yq '.params.theme_color') "★" "/System/Library/Fonts/Apple Symbols.ttf")
	@time (for color in $$(find "${content_dir}" -type f -iname "*.md" -exec grep -E "^  theme_color: " {} \; | cut -d ':' -f 2 | cut -d ' ' -f 2 | sort | uniq); do _tools/generate-icons.sh . "$${color//\"/}" "★" "/System/Library/Fonts/Apple Symbols.ttf"; done)

.PHONY: beautify
beautify: ## Beautifies goldmark output
	$(info ==> Beautifying ${base_url} goldmark output...)
	@time (find "${output_dir}" -type f -name "*.html" -exec sed -i '' -E 's/ class="footnote(s|-(back)?ref)"//g ; s/ class="ancestor"//g' {} \;)
# 	@time (find "${output_dir}" -type f -name "*.html" -exec sed -i '' -e ':a' -e 'N' -e '$!ba' -e 's/<div class="footnotes" role="doc-endnotes">\n<hr>/<div class="footnotes" role="doc-endnotes">/' {} \;)

.PHONY: server
server: icons ## Builds and serves the site
	$(info ==> Building and serving ${base_url} locally...)
	@hugo server --source exampleSite/

.PHONY: rsync
rsync: ## Syncs the artifact to the remote server
	$(info ==> Rsyncing ${base_url}'s content to SSH host ${ssh_host}...)
	@time (rsync -e "ssh -p ${ssh_port}" -vcrlptDShP --delete --rsync-path 'sudo -u ${ssh_user} rsync' --chmod=Du=rwx,Dgo=rx,Fu=rw,Fgo=r \
		--exclude=.DS_Store \
		--exclude=._* \
		--exclude=.git \
		--exclude=.gitignore \
		--exclude=.github \
		--exclude=Makefile \
		"${output_dir}/" \
		${ssh_user}@${ssh_host}:${ssh_path})
	@time (curl -s -A "DeploymentLogger/1.0" --compressed https://${base_url}/deployed)

.PHONY: scprobots
scprobots: ## Copies robots.txt to the remote server
	$(info ==> Scp'ing ${base_url} robots.txt to SSH host ${ssh_host}...)
	@time (scp -P ${ssh_port} exampleSite/static/robots.txt ${ssh_user}@${ssh_host}:${ssh_path})

.PHONY: compress
compress: ## Compresses select artifacts on the remote server
	$(info ==> Compressing ${base_url} via SSH...)
	@time (ssh -p ${ssh_port} ${ssh_user}@${ssh_host} 'for file in $$(find ${ssh_path} -type f -size +1100c -regex ".*\.\(css\|map\|html\|js\|json\|svg\|txt\|xml\)$$"); do printf . && gzip -kf -9 "$${file}" && brotli -kf -q 9 "$${file}"; done; echo')

.PHONY: compressrobots
compressrobots: ## Compresses robots.txt on the remote server
	$(info ==> Compressing ${base_url} robots.txt via SSH...)
	@time (ssh -p ${ssh_port} ${ssh_user}@${ssh_host} 'gzip -kf -9 ${ssh_path}/robots.txt && brotli -kf -q 9 ${ssh_path}/robots.txt')

.PHONY: deploy
deploy: build rsync compress ## Builds and deploys the artifact to the remote server
	$(info ==> Deployed ${base_url} to SSH host ${ssh_host}...)

.PHONY: deployrobots
deployrobots: robots scprobots compressrobots ## Builds and deploys robots.txt to the remote server
	$(info ==> Deployed ${base_url} robots.txt to SSH host ${ssh_host}...)

.PHONY: clean
clean: ## Cleans the artifact
	$(info ==> Cleaning ${base_url})
	@time (rm -rf exampleSite/.hugo_build.lock "${output_dir}" assets/assets/icons exampleSite/resources)

.PHONY: draft
draft: ## Creates a draft from a template with a UUID
	$(info ==> Creating draft at exampleSite/content/posts/_drafts/${current_date}.md ...)
	@sed -e "s/  uuid:/  uuid: $$(uuidgen)/" archetypes/posts_makefile.md > exampleSite/content/posts/_drafts/${current_date}.md
