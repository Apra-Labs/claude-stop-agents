@echo off
rem Stop Claude Code agents that have a running process (pid).
rem Usage: stop-agents [-y|--yes] [-n|--dry-run] [-s|--state blocked,working]
rem Same flags as the bash version (stop-agents) for macOS/Linux.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0stop-agents.ps1" %*
exit /b %ERRORLEVEL%
