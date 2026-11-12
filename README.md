# claude-stop-agents

Stop every running [Claude Code](https://github.com/anthropics/claude-code) background agent with one command.

Claude Code can stop background sessions one at a time (`claude stop <id>`). This tool reads `claude agents --json` and stops each agent that still has a running process (one that has a `pid`). The conversations are kept, so `claude attach <id>` or `claude --resume` can reopen them.

## Usage

The command and flags are the same on Windows, macOS and Linux:

```
stop-agents                      # list agents with a running process, confirm, stop them
stop-agents -y | --yes           # stop without asking
stop-agents -n | --dry-run       # only list what would be stopped
stop-agents -s blocked,working   # also restrict by state (or --state=blocked)
stop-agents -h | --help
```

Example:

```
$ stop-agents
Found 2 agent(s) with a running process:
ID        PID    STATE    STATUS  NAME
1a2b3c4d  17232  blocked  idle    refactor auth module
5e6f7a8b  26732  working  busy    fix flaky tests
Stop all of them? [y/N] y
Stopping 1a2b3c4d (refactor auth module)... ok
Stopping 5e6f7a8b (fix flaky tests)... ok
Done: 2 stopped, 0 failed.
```

> If you run it from inside a Claude Code agent, that agent stops too.

## Install

Put the files in a directory on your `PATH`. `~/.local/bin` works well because Claude Code's native installer puts `claude` there.

**macOS / Linux (bash or zsh)**: needs `jq` or `python3`.

```sh
cp stop-agents ~/.local/bin/ && chmod +x ~/.local/bin/stop-agents
```

**Windows (Command Prompt or PowerShell)**: copy both files. `stop-agents.cmd` runs `stop-agents.ps1` with Windows PowerShell.

```bat
copy stop-agents.cmd %USERPROFILE%\.local\bin\
copy stop-agents.ps1 %USERPROFILE%\.local\bin\
```

## Files

| File | Platform |
|---|---|
| `stop-agents` | macOS / Linux (bash, zsh) |
| `stop-agents.cmd` + `stop-agents.ps1` | Windows |
