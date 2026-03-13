`design-system-auditor.toml` configures the `prism-oracle` Figma/design-system review agent.
`pattern-checker.toml` configures the `pattern-weaver` code-pattern review agent.
`lorekeeper.toml` configures the context documentation maintenance agent.
`codex/config.toml` now registers the three Codex agents explicitly: `prism-oracle`, `pattern-weaver`, and `lorekeeper`.
`install.sh` now treats `~/.codex/agents` like `~/.codex/skills`: it backs up a pre-existing non-symlink path, removes the destination, and symlinks the repo's `codex/agents` directory into place.
There is also a new unstaged Claude agent draft at `claude/agents/architecture-reviewer.md`; it is separate from the Codex agent setup and is not referenced by `install.sh`.
