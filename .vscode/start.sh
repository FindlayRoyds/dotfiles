#!/usr/bin/env bash

rm "$(dirname "$0")/.gitignore"
touch "$(dirname "$0")/.gitignore"

echo "settings.json" >> "$(dirname "$0")/.gitignore"
echo "start.sh" >> "$(dirname "$0")/.gitignore"
echo ".gitignore" >> "$(dirname "$0")/.gitignore"
