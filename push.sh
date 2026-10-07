#!/bin/bash
# Usage: ./push.sh
# Everything is asked interactively: branch, commit type, message.
# Commit format: [HRO][branch] type: message

TYPES=(feat fix doc style refactor test chore perf build)

if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "Error: not in a git repository"
    exit 1
fi

CURRENT_BRANCH=$(git branch --show-current)
mapfile -t BRANCHES < <(git for-each-ref --format='%(refname:short)' refs/heads)

if [ "${#BRANCHES[@]}" -eq 0 ]; then
    echo "Error: no local branch found (no commit yet?)"
    exit 1
fi

# --- Branch selection ---
echo "Choose the branch (Enter = stay on the current one, marked with *):"
for i in "${!BRANCHES[@]}"; do
    MARK=" "
    [ "${BRANCHES[$i]}" = "$CURRENT_BRANCH" ] && MARK="*"
    echo " $MARK $((i + 1))) ${BRANCHES[$i]}"
done

while true; do
    if [ "${#BRANCHES[@]}" -le 9 ]; then
        read -n 1 -s -p "> " CHOICE
        echo
    else
        read -r -p "> " CHOICE
    fi

    if [ -z "$CHOICE" ] && [ -n "$CURRENT_BRANCH" ]; then
        BRANCH="$CURRENT_BRANCH"
        break
    fi

    if [[ "$CHOICE" =~ ^[0-9]+$ ]] && [ "$((10#$CHOICE))" -ge 1 ] && [ "$((10#$CHOICE))" -le "${#BRANCHES[@]}" ]; then
        BRANCH="${BRANCHES[$((10#$CHOICE - 1))]}"
        break
    fi
    echo "Invalid choice, enter a number between 1 and ${#BRANCHES[@]}."
done
echo "Branch: $BRANCH"

if [ "$BRANCH" != "$CURRENT_BRANCH" ]; then
    echo "Switching to '$BRANCH'..."
    git switch "$BRANCH" || exit 1
fi

# --- Type selection ---
echo "Choose the commit type:"
for i in "${!TYPES[@]}"; do
    echo "  $((i + 1))) ${TYPES[$i]}"
done

while true; do
    read -n 1 -s -p "> " CHOICE
    echo
    if [[ "$CHOICE" =~ ^[1-9]$ ]] && [ "$CHOICE" -le "${#TYPES[@]}" ]; then
        TYPE="${TYPES[$((CHOICE - 1))]}"
        break
    fi
    echo "Invalid choice, press a number between 1 and ${#TYPES[@]}."
done
echo "Type: $TYPE"

# --- Message ---
while true; do
    read -r -p "Commit message: " MESSAGE
    if [ -n "${MESSAGE// /}" ]; then
        break
    fi
    echo "The message cannot be empty."
done

git add . || exit 1
git commit -m "[HRO][$BRANCH] $TYPE: $MESSAGE" || exit 1
git push