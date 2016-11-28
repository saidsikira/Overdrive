#!/bin/sh
set -o errexit
set -o errtrace
set -o pipefail

PROJECT_NAME="Overdrive"
DOC_FOLDER="latest"
SOURCE_BRANCH="master"
GITHUB_URL="https://github.com/arikis/Overdrive"

echo "[GIT]   Cloning from $GITHUB_URL\n"

if [ -d $PROJECT_NAME ]; then
	git -C $PROJECT_NAME pull origin $SOURCE_BRANCH
else
	git clone --branch $SOURCE_BRANCH --single-branch $GITHUB_URL".git"
fi

# Go to the Project folder
pushd $PROJECT_NAME

# Fetch all tags
git fetch --tags

# Get latest tag
LATEST_TAG=$(git describe --tags `git rev-list --tags --max-count=1`)

# Checkout to the latest tag
echo "[GIT]   Checking out $LATEST_TAG\n"

git checkout tags/$LATEST_TAG

popd

echo "[JAZZY] Generating documentation \n"

# Generate documentation with jazzy
jazzy \
		--clean \
		--output ./latest \
		--author "Swiftable" \
		--author_url "http://swiftable.io" \
		--theme fullwidth \
		--head "$(cat head.html)" \
		--readme $PROJECT_NAME"/README.md" \
		--documentation $PROJECT_NAME"/Documentation/*.md" \
		--hide-documentation-coverage \
		--github_url $GITHUB_URL \
		--module Overdrive \
		--module-version $LATEST_TAG
