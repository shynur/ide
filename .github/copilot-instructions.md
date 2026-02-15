This is a repository for building a Docker image providing a cutting-edge C++ development environment.
It mainly includes: GCC 16, CMake 4, Conan 2.

Please follow these guidelines when contributing:

## Code Standards

### Format
- Text files must end with `\n`.
- JSON files use **TAB** for indentation.
- YAML files use **2 spaces** for indentation.
- No blank lines in YAML files.
- In English text, separate sentences with **two spaces** at the end of each sentence, or start a new line directly.

### GitHub Actions (Workflows)
- When cloning is involved, clone as little as possible.  For example, check if Git's `--depth` parameter can be set to 1.

### Code
- Do NOT use `exit 0` in Bash; prefer a standalone `exit`.

### Git
- For a simple change, the commit message starts with `; `.

## Repository Structure
- `HOME/`: Provides user configuration files.  Files will be copied into `/root/`.
- `make-gcc/`: The `src/` subdirectory contains GCC source code; the `build/` subdirectory is used for configuring and building.

## Key Guidelines
- Any code you write must be **fully commented**.
