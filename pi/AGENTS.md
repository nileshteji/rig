# Pi Global Instructions

## Available Specialist Skills

This dotfiles setup installs these Pi skills under `~/.pi/agent/skills`:
- `scout`
- `architect`
- `architecture-reviewer`
- `forger`
- `sentinel`
- `lorekeeper`
- `figma-design-guardian`

## Usage Notes

- Pi does not have built-in sub-agents. Prefer loading a specialist skill when the task matches.
- Invoke a skill explicitly with `/skill:<name>` when needed.
- For reusable runtime behavior, prefer Pi extensions over prompt-only skills.
- For project-specific conventions, read `AGENTS.md` files from the current repo.
