# Westeros battlefield

Real-time PixiJS dashboard for Claude Code agent teams, themed as a Game of Thrones battlefield. Riders enter as teammates spawn, Jon Snow rides out to hand over quests, and strikes a rider down when its task is completed and it is shut down. No image assets; every rider is a rigged puppet drawn in code.

Installed by `install.sh` as a symlink at `~/.claude/westeros`. The `/westeros` skill (in `claude/skills/westeros`) starts the server and opens http://localhost:7777. Add `?demo=1` for a staged battle.

Data comes from `~/.claude/teams/session-*/config.json`, `~/.claude/tasks/session-*/`, and the hook log `events.jsonl` written by `hook.sh` (registered in `claude/settings.json` for TeammateIdle, TaskCreated, TaskCompleted, SubagentStart, SubagentStop).

Roster: Jon Snow (lead), Daenerys (scout), Tyrion (architect), Tywin (architecture-reviewer), Arya (forger), Bran (sentinel), Samwell (lorekeeper), Sansa (figma-design-guardian). Agent definitions live in `claude/agents`.
