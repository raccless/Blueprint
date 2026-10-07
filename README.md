# Blueprint

Blueprint is a Zsh CLI tool for quickly creating files and directories from the command line or from a reusable structure file.

It supports two creation modes:

- **Manual mode** for fast, one-command project scaffolding.
- **Blueprint mode** for creating a complete directory structure from a `.txt` file.
- **Scan mode** for inspecting an existing directory and generating a reusable structure file.

## Features

- Create multiple files from one command.
- Create multiple directories from one command.
- Switch between file and directory creation modes while processing arguments.
- Create complete directory structures from a blueprint file.
- Recursively scan existing directory structures.
- Generate `structure.txt` files that can be reused with Blueprint.
- Reuse the same `create_file` and `create_directory` functions across different modes.
- Avoid overwriting existing files or directories.
- Skip blank lines in blueprint files.
- Validate basic command usage before processing input.

## Usage

### Manual mode

Manual mode is designed for speed.

```zsh
blueprint 1 f main.py game.py style.css d assets/ f assets/image.png
```

The `f` and `d` arguments change the current mode:

```text
f             switch to file mode
d             switch to directory mode
<path>        create the path using the current mode
```

For example:

```zsh
blueprint 1 \
  f main.py game.py config.py \
  d src/ assets/ \
  f src/game.py assets/player.png
```

This creates:

```text
main.py
game.py
config.py
src/
assets/
src/game.py
assets/player.png
```

> [!IMPORTANT]
> In manual mode, a path is interpreted according to the most recently selected mode. A path appearing before `f` or `d` has no selected type.

### Blueprint-file mode

Blueprint-file mode reads one instruction per line from a `.txt` file.

Example:

```text
f main.py
f settings.py

d core/
f core/game.py
f core/state.py
f core/assets.py

d states/
f states/menu.py
f states/play.py
f states/pause.py
f states/gameover.py

d assets/
d assets/images/
d assets/audio/
d assets/fonts/
```

Run it with:

```zsh
blueprint 2 structure.txt
```

The grammar is intentionally simple:

```text
f <path>    create a file
d <path>    create a directory
```

Blank lines are ignored.

> [!IMPORTANT]
> Blueprint-file mode uses one instruction per line. Do not place multiple `f` or `d` instructions on the same line.

### Scan mode

Scan mode examines an existing directory recursively and generates a `structure.txt` file inside the directory being scanned.

```zsh
blueprint scan .
```

or:

```zsh
blueprint scan someproject/
```

For example:

```text
someproject/
├── main.py
├── src/
│   ├── game.py
│   └── state.py
└── assets/
    └── player.png
```

can produce:

```text
f someproject/main.py
d someproject/src
f someproject/src/game.py
f someproject/src/state.py
d someproject/assets
f someproject/assets/player.png
```

The generated `structure.txt` can then be used with:

```zsh
blueprint 2 someproject/structure.txt
```

> [!NOTE]
> `structure.txt` describes the scanned project but does not include itself as an entry.

Running `scan` again regenerates the file so that it represents the current state of the directory.

---

# Concepts and Zsh Syntax Used

This project is also a practical introduction to Zsh scripting. The following concepts are used throughout Blueprint.

## Shebang

```zsh
#!/bin/zsh
```

The shebang tells the operating system which interpreter should execute the script.

In this project, the interpreter is Zsh.

## Making a Script Executable

```zsh
chmod u+x blueprint.zsh
```

`u+x` gives the file's owner permission to execute it.

The script can then be run with:

```zsh
./blueprint.zsh
```

If the script is placed somewhere in `$PATH`, it can be invoked directly:

```zsh
blueprint
```

---

# Variables

Variables are assigned without `$`:

```zsh
filename="main.py"
```

The `$` is used when retrieving the value:

```zsh
echo "$filename"
```

> [!IMPORTANT]
> Do not use `$` when assigning a variable.

Correct:

```zsh
name="Alex"
```

Incorrect:

```zsh
$name="Alex"
```

## Quoting Variables

Prefer:

```zsh
"$filename"
```

instead of:

```zsh
$filename
```

Quoting prevents whitespace and other characters from being interpreted as separate shell arguments.

---

# Positional Parameters

Scripts receive command-line arguments through positional parameters.

```zsh
$0
```

The command or script used to invoke the script.

```zsh
$1
```

The first argument.

```zsh
$2
```

The second argument.

And so on.

For example:

```zsh
blueprint 1 f main.py
```

gives:

```text
$1 = 1
$2 = f
$3 = main.py
```

## Number of Arguments

```zsh
$#
```

contains the number of positional arguments.

For:

```zsh
blueprint 1 f main.py
```

`$#` is `3`.

This is useful for basic command validation:

```zsh
if [[ $# -lt 3 ]]; then
    echo "Usage: ..."
    exit 1
fi
```

## All Arguments

```zsh
$@
```

represents the positional arguments.

In this project, we use:

```zsh
"${@:2}"
```

to process every argument starting with `$2`.

For:

```zsh
blueprint 1 f main.py game.py
```

the loop receives:

```text
f
main.py
game.py
```

---

# Reading Input

The `read` command reads input from standard input.

```zsh
read line
```

In Blueprint, it is used to read a blueprint file one line at a time:

```zsh
while read line
do
    processing_and_splitting "$line"
done < "$2"
```

The redirection:

```zsh
< "$2"
```

makes the specified file become the loop's standard input.

---

# Standard Input and Arguments

These are different concepts.

This:

```zsh
blueprint 2 structure.txt
```

passes `structure.txt` as an argument:

```zsh
$2 = structure.txt
```

This:

```zsh
blueprint 2 < structure.txt
```

redirects the contents of the file into standard input.

Blueprint uses the first approach and explicitly redirects the file into the `while read` loop.

---

# Functions

Functions group reusable operations.

Blueprint uses functions such as:

```zsh
create_file()
{
    ...
}
```

and:

```zsh
create_directory()
{
    ...
}
```

A function can receive arguments:

```zsh
create_file "main.py"
```

Inside the function:

```zsh
$1
```

refers to `main.py`.

> [!IMPORTANT]
> Positional parameters are relative to the current function call. `$1` inside a function is the first argument passed to that function, not necessarily the script's `$1`.

Functions make it possible for both manual mode and blueprint-file mode to reuse the same creation logic.

---

# Conditional Statements

Zsh uses:

```zsh
if [[ condition ]]; then
    ...
elif [[ another_condition ]]; then
    ...
else
    ...
fi
```

Blueprint uses this for command selection and validation.

Example:

```zsh
if [[ $1 == 1 ]]; then
    ...
elif [[ $1 == 2 ]]; then
    ...
else
    ...
fi
```

## `[[ ... ]]`

`[[ ... ]]` is Zsh's conditional expression syntax.

Examples:

```zsh
[[ "$name" == "f" ]]
```

String comparison.

```zsh
[[ -z "$name" ]]
```

Checks whether a string is empty.

```zsh
[[ -n "$name" ]]
```

Checks whether a string is not empty.

```zsh
[[ -f "$path" ]]
```

Checks whether a regular file exists.

```zsh
[[ -d "$path" ]]
```

Checks whether a directory exists.

```zsh
[[ -e "$path" ]]
```

Checks whether a filesystem entry exists.

---

# String Tests

## `-z`

```zsh
[[ -z "$value" ]]
```

True when `$value` is an empty string.

Blueprint uses this to detect blank lines:

```zsh
if [[ -z "$line" ]]; then
    return
fi
```

## `-n`

```zsh
[[ -n "$value" ]]
```

True when `$value` is not empty.

The difference is:

```text
-z    empty
-n    not empty
```

---

# File and Directory Tests

```zsh
[[ -f "$path" ]]
```

True when the path is a regular file.

```zsh
[[ -d "$path" ]]
```

True when the path is a directory.

```zsh
[[ -e "$path" ]]
```

True when the path exists.

Blueprint uses these to distinguish files and directories during scanning and creation.

---

# Logical Operators

## AND

```zsh
&&
```

Both conditions must be true.

```zsh
[[ "$type" == "f" && -n "$path" ]]
```

## OR

```zsh
||
```

At least one condition must be true.

## NOT

```zsh
!
```

Negates a condition.

---

# Loops

## `for`

A `for` loop processes a list of values.

```zsh
for name in Alice Bob Charlie
do
    echo "$name"
done
```

Blueprint uses a `for` loop to process command-line arguments:

```zsh
for argument in "${@:2}"
do
    ...
done
```

It is also used during directory scanning.

---

# `while`

A `while` loop repeatedly executes while its condition succeeds.

Blueprint uses:

```zsh
while read line
do
    processing_and_splitting "$line"
done < "$2"
```

This reads a blueprint file line by line.

---

# `return`

`return` exits the current function.

For example:

```zsh
processing_and_splitting()
{
    if [[ -z "$line" ]]; then
        return
    fi

    ...
}
```

This does **not** terminate the entire script.

It simply returns from `processing_and_splitting()`.

> [!IMPORTANT]
> `return` and `exit` have different scopes.

```zsh
return
```

leaves a function.

```zsh
exit
```

terminates the script.

---

# `exit`

`exit` terminates the script.

It can optionally receive an exit status:

```zsh
exit 1
```

A common convention is:

```text
0       success
non-zero failure
```

Blueprint uses `exit 1` when command usage is invalid.

---

# Exit Status

Every command produces an exit status.

```zsh
$?
```

contains the exit status of the most recently executed command.

Generally:

```text
0       success
non-zero failure
```

Examples:

```zsh
true
echo $?
```

produces:

```text
0
```

while:

```zsh
false
echo $?
```

produces a non-zero value.

> [!WARNING]
> `$?` changes after commands execute, so check it immediately if you need its value.

---

# `touch`

Blueprint uses:

```zsh
touch "$1"
```

to create files.

If the file does not exist, `touch` creates it.

If it already exists, `touch` updates its modification timestamp rather than deleting its contents.

Blueprint checks for an existing path before calling `touch`.

---

# `mkdir`

Blueprint uses:

```zsh
mkdir -p "$1"
```

The `-p` option creates missing parent directories as necessary.

For example:

```zsh
mkdir -p "src/game/assets"
```

can create:

```text
src/
└── game/
    └── assets/
```

as required.

---

# Arrays and Word Splitting

Blueprint's blueprint-file parser uses:

```zsh
parts=(${=line})
```

This splits a non-empty line into whitespace-separated parts.

For:

```text
f main.py
```

the array contains:

```text
parts[1] = f
parts[2] = main.py
```

The number of elements can be checked with:

```zsh
${#parts[@]}
```

For example:

```zsh
line="f main.py"
parts=(${=line})

echo "${#parts[@]}"
```

produces:

```text
2
```

> [!IMPORTANT]
> The current Blueprint grammar treats whitespace as the separator between the instruction and path. Paths containing spaces are therefore not currently supported by this simple parser.

---

# `continue`

`continue` skips the rest of the current loop iteration and moves to the next iteration.

The scanner uses this concept to skip its own output file:

```zsh
if [[ "$item" == "$output_file" ]]; then
    continue
fi
```

This prevents:

```text
f ./structure.txt
```

from appearing inside `structure.txt`.

---

# Redirection

## Input redirection

```zsh
command < file.txt
```

Feeds the contents of `file.txt` into the command's standard input.

Blueprint uses:

```zsh
done < "$2"
```

to feed the blueprint file into `while read`.

## Output redirection

```zsh
command > file.txt
```

Writes output to a file, replacing its previous contents.

## Append redirection

```zsh
command >> file.txt
```

Appends output to the end of a file.

The scanner uses `>>` so that recursive calls can all write to the same `structure.txt`.

## Emptying a file

```zsh
: > "$output_file"
```

The `:` command does nothing successfully, while the redirection still takes effect.

This effectively clears the file before a new scan.

It allows `scan` to regenerate `structure.txt` instead of endlessly appending new scans.

---

# Recursion

The scanner uses recursion to walk through nested directories.

A simplified version looks like:

```zsh
scan_directory()
{
    directory="$1"

    for item in "$directory"/*
    do
        if [[ -f "$item" ]]; then
            echo "f $item"

        elif [[ -d "$item" ]]; then
            echo "d $item"
            scan_directory "$item"
        fi
    done
}
```

When a directory is encountered, the function calls itself with that directory.

For:

```text
project/
├── main.py
└── src/
    ├── game.py
    └── states/
        └── menu.py
```

the scanner conceptually does:

```text
scan project/
    |
    +-- main.py
    |
    +-- src/
          |
          +-- game.py
          |
          +-- states/
                |
                +-- menu.py
```

This allows Blueprint to handle arbitrarily nested directory structures.

---

# Blueprint's Internal Structure

The script is intentionally divided into reusable pieces.

```text
create_file()
    |
    +-- creates a file

create_directory()
    |
    +-- creates a directory

processing_and_splitting()
    |
    +-- parses one blueprint-file line

scan_directory()
    |
    +-- recursively scans directories

main argument handling
    |
    +-- option 1: manual creation
    +-- option 2: blueprint-file creation
    +-- scan: structure generation
```

This separation keeps the individual operations simple and makes the main command handling easier to extend.

---

# Roadmap

- [x] Create multiple files from a single command
- [x] Create directories from a single command
- [x] Support switching between file and directory modes
- [x] Create structures from a blueprint file
- [x] Support nested directory structures
- [x] Prevent basic accidental overwriting of existing paths
- [x] Add basic command validation
- [x] Add recursive directory scanning
- [x] Generate `structure.txt` from an existing directory
- [ ] Improve blueprint-file input validation
- [ ] Improve usage/help output
- [ ] Clean up and refactor the script
- [ ] Add removal support for files and directories
- [ ] Add safeguards and confirmation for destructive operations
- [ ] Consider additional scan/output options

---

# Planned Destructive Operations

Removal support is intentionally kept separate from creation and scanning.

Potential future usage could look like:

```zsh
blueprint remove ...
```

Before implementing this, the tool should have clear safeguards.

> [!WARNING]
> Recursive deletion is destructive. Blueprint should never silently remove an entire directory tree.

Possible safeguards include:

- Explicit confirmation.
- A clear preview of what will be removed.
- Refusing dangerous paths such as `/`.
- Requiring an explicit recursive flag for directories.
- Providing a dry-run mode.

---

# Design Philosophy

Blueprint is intended to be:

- Fast to use.
- Simple to understand.
- Predictable.
- Composable with normal shell commands.
- Useful for both one-off scaffolding and reusable project structures.
- Small enough that its implementation remains understandable.

The two main creation modes deliberately serve different purposes:

```text
blueprint 1 ...
```

is optimized for **speed**.

```text
blueprint 2 structure.txt
```

is optimized for **repeatability and explicit structure**.

```text
blueprint scan .
```

is optimized for **turning an existing filesystem structure into a reusable blueprint**.
