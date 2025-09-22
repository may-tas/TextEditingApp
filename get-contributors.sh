#!/bin/bash

echo "Finding contributors from Git history..."

git log --format='%aN <%aE>' | sort -u | while read name email; do
    if [[ $email == *"@users.noreply.github.com"* ]]; then
        username=$(echo $email | cut -d'@' -f1 | cut -d'+' -f2)
        echo "npx all-contributors add $username code"
    else
        echo "# Found contributor: $name $email"
        echo "# Add manually: npx all-contributors add [github-username] code"
    fi
done
