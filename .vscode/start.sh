#!/usr/bin/env bash

cp -r "$(dirname "$0")" .vscode

echo "settings.json" >> ".vscode/.gitignore"
echo ".gitignore" >> ".vscode/.gitignore"

rm ".vscode/start.sh"
