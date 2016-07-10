#!/bin/sh
set -o errexit
set -o errtrace
set -o pipefail

PROJECT_NAME="Overdrive"
DOC_FOLDER="latest"
SOURCE_BRANCH="master"
GITHUB_URL="https://github.com/swiftable/Overdrive"

# if [ "$TRAVIS_PULL_REQUEST" != "false" -o "$TRAVIS_BRANCH" != $SOURCE_BRANCH ]; then exit 0; fi

if [ -d $PROJECT_NAME ]; then
	git -C $PROJECT_NAME pull origin master
else
	git clone --branch $SOURCE_BRANCH $GITHUB_URL
fi

# Generate documentation with jazzy

cd Overdrive &&
jazzy \
		--clean \
		--swift-version 2.2 \
		--output ../latest \
		--author "Swiftable" \
		--author_url "swiftable.io" \
		--theme fullwidth \
		--head "$(cat ../head.html)" \
		--github_url $GITHUB_URL \
		--readme "README.md"