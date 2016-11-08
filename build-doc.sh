#!/bin/sh
set -o errexit
set -o errtrace
set -o pipefail

PROJECT_NAME="Overdrive"
DOC_FOLDER="latest"
SOURCE_BRANCH="master"
GITHUB_URL="https://github.com/arikis/Overdrive"

#if [ "$TRAVIS_PULL_REQUEST" != "false" -o "$TRAVIS_BRANCH" != $SOURCE_BRANCH ]; then exit 0; fi

echo "[GIT]   Cloning from $GITHUB_URL"
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

popd

# Checkout to the latest tag
echo "[GIT]   Checking out $LATEST_TAG"

echo "[JAZZY] Generating documentation . . ."

# Generate documentation with jazzy
jazzy \
		--clean \
		--output ./latest \
		--author "Swiftable" \
		--author_url "swiftable.io" \
		--theme fullwidth \
		--head "$(cat head.html)" \
		--readme "Overdrive/README.md" \
		--documentation "Overdrive/Documentation/*.md" \
		--github_url $GITHUB_URL \
		--module Overdrive \
		--module-version $LATEST_TAG
