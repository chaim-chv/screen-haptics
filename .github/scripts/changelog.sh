#!/bin/sh
set -eu

# Get the previous tag before the current one
CURRENT_TAG=$(git describe --tags --exact-match HEAD 2>/dev/null || true)
if [ -n "$CURRENT_TAG" ]; then
    LAST_TAG=$(git tag --sort=-creatordate | grep -v "^$CURRENT_TAG$" | head -n 1 || true)
else
    LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || true)
fi

if [ -n "$LAST_TAG" ]; then
    RANGE="$LAST_TAG..HEAD"
else
    RANGE="HEAD"
fi

# Parse commits
git log $RANGE --pretty=format:"%s%n%b%n----" | awk '
BEGIN { feats=""; fixes=""; block=""; first="" }
/^----$/ {
    # Only conventional commits: feat(...) or feat: etc.
    l = tolower(first)
    if (l ~ /^feat(\([^)]+\))?:/) feats = feats "- " first "\n"
    else if (l ~ /^fix(\([^)]+\))?:/) fixes = fixes "- " first "\n"
    block=""; first=""
    next
}
block=="" { first=$0 }
{ block = block $0 "\n" }
END {
    l = tolower(first)
    if (l ~ /^feat(\([^)]+\))?:/) feats = feats "- " first "\n"
    else if (l ~ /^fix(\([^)]+\))?:/) fixes = fixes "- " first "\n"

    if (feats!="") print "### Features\n" feats
    if (fixes!="") print "### Bug Fixes\n" fixes
}'
