#!/bin/sh

set -o errexit
set -o errtrace
set -o pipefail

PROJECT_NAME="Overdrive" #Name of the project on
DOC_FOLDER="master"

# Fetch newest version from Github
if [ -d $PROJECT_NAME ]; then
  git -C $PROJECT_NAME pull origin master
else
  git clone --depth 1 --branch master https://github.com/arikis/Overdrive.git
fi

echo "Generating documentation"

jazzy \
		--clean \
		--swift-version 2.2 \
		--output master \
		--author "Swiftable" \
		--author_url "swiftable.io" \
		--theme fullwidth \
		--head "$(cat head.html)"
		--github_url "https://github.com/swiftable/Overdrive" \
		--readme "./README.md"