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

