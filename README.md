# push.sh

An interactive Bash script that stages, commits and pushes in one go, while enforcing a consistent commit message format.

```
[INITIALS][branch] type: message
```

Example: `[HRO][feature-x] feat: add login system`

The initials are not hardcoded: the script asks for them each time.

## Features

- Asks for your initials (no default value)
- Lists the existing local branches and lets you pick one with its number
- Switches to the chosen branch automatically if you are not already on it
- Asks for the commit type with a single key press (no Enter needed)
- Asks for the commit message and refuses empty ones
- Runs `git add .`, `git commit` and `git push` for you
- Stops at the first error, so nothing is pushed if the commit fails

## Requirements

- Bash 4 or newer (the script uses `mapfile`)
- Git
- A repository with at least one commit

> macOS ships with Bash 3.2 by default. Install a recent version with `brew install bash` and run the script with it.

## Installation

Copy `push.sh` to the root of your repository and make it executable:

```bash
chmod +x push.sh
```

To use it from any repository, put it in a permanent folder and add an alias:

```bash
mkdir -p ~/scripts && mv push.sh ~/scripts/
echo 'alias gp="~/scripts/push.sh"' >> ~/.bashrc   # or ~/.zshrc
source ~/.bashrc
```

## Usage

The script takes no arguments. Run it from inside a git repository:

```bash
./push.sh
```

Example session:

```
$ ./push.sh
Initials: HRO
Choose the branch (Enter = stay on the current one, marked with *):
   1) dev
   2) feature-x
 * 3) main
> 2
Branch: feature-x
Switching to 'feature-x'...
Choose the commit type:
  1) feat
  2) fix
  3) doc
  4) style
  5) refactor
  6) test
  7) chore
  8) perf
  9) build
> 1
Type: feat
Commit message: add login system
[feature-x 5e117df] [HRO][feature-x] feat: add login system
```

Then `git push` runs.

## Commit types

| Key | Type     | Use for                                  |
|-----|----------|------------------------------------------|
| 1   | feat     | A new feature                            |
| 2   | fix      | A bug fix                                |
| 3   | doc      | Documentation changes                    |
| 4   | style    | Formatting, no change in behaviour       |
| 5   | refactor | Code restructuring without new behaviour |
| 6   | test     | Adding or updating tests                 |
| 7   | chore    | Maintenance, tooling, configuration      |
| 8   | perf     | Performance improvements                 |
| 9   | build    | Build system and dependencies            |

To change the list, edit the `TYPES` array at the top of the script (9 entries maximum, one per key).

## Customization

- **Initials**: asked at each run, letters, digits, `-` and `_` only. Nothing is stored or pre-filled.
- **Push to a specific remote or set the upstream**: replace the last line with `git push -u origin "$BRANCH"`.

## Good to know

- `git add .` stages **everything** in the repository, including files you may not want to commit. Check `git status` first and keep a proper `.gitignore`.
- Uncommitted changes follow you when the script switches branch, unless they conflict with the target branch. In that case git refuses the switch and the script stops.
- Only local branches are listed. A branch that exists only on the remote must be fetched and checked out first.
- With more than 9 branches, the script asks for the number followed by Enter instead of a single key press.
- If the branch has no upstream yet, the final `git push` fails. Use the `git push -u origin "$BRANCH"` variant above.