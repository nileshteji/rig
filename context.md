# Repository Context

## `install.sh`
Interactive and non-interactive dotfiles installer. It bootstraps tool installs, initializes the `skills` submodule (retrying over HTTPS if SSH auth is not ready yet), symlinks shared configs and skills into user directories, installs the vendored `lite-samurai` Oh My Zsh theme, and supports a `--default` path for the standard setup without optional gstack.

## `Makefile`
Thin bootstrap entrypoint for new machines. `make` delegates to `./install.sh --default` so the shell script remains the source of truth instead of duplicating installer logic.

## `zsh/themes/lite-samurai.zsh-theme`
Vendored custom Oh My Zsh theme used by `zsh/.zshrc` so fresh laptops can reproduce the same prompt without relying on files from an existing machine.
