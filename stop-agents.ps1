# Stop Claude Code agents that still have a running process (a "pid" in
# "claude agents --json"). Windows version; run via stop-agents.cmd.
#
# Usage: stop-agents [-y|--yes] [-n|--dry-run] [-s|--state blocked,working]
#   -y, --yes       stop without asking
#   -n, --dry-run   only list what would be stopped
#   -s, --state     additionally restrict to these states (comma-separated)
# Conversations are kept: "claude attach <id>" or "claude --resume" reopens them.
# Same flags as the bash version (stop-agents) for macOS/Linux.

$ErrorActionPreference = 'Stop'

$Yes = $false; $DryRun = $false; $State = @()
for ($i = 0; $i -lt $args.Count; $i++) {
    $arg = [string]$args[$i]
    switch -Regex ($arg) {
        '^(-y|--yes)$'      { $Yes = $true; break }
        '^(-n|--dry-run)$'  { $DryRun = $true; break }
        '^(-s|--state)$'    { $i++; if ($i -lt $args.Count) { $State += [string]$args[$i] }; break }
        '^--state=(.*)$'    { $State += $Matches[1]; break }
        '^(-h|--help)$'     { Get-Content $PSCommandPath -TotalCount 9 | ForEach-Object { $_ -replace '^# ?', '' }; exit 0 }
        default             { Write-Host "unknown option: $arg (see --help)"; exit 2 }
    }
}
$State = @($State -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ })

$raw = & claude agents --json
if ($LASTEXITCODE -ne 0) { Write-Host "claude agents --json failed (exit $LASTEXITCODE)"; exit 1 }

# Assign first: in Windows PowerShell 5.1, ConvertFrom-Json emits the array as a single object.
$parsed = ($raw | Out-String) | ConvertFrom-Json
$agents = @($parsed)

# Only agents that still have a live process (a "pid" field) are stopped.
$targets = @($agents | Where-Object {
    $_.pid -and ($State.Count -eq 0 -or $State -contains $_.state)
})

if ($targets.Count -eq 0) { Write-Host 'No agents with a running process (pid) found.'; exit 0 }

Write-Host "Found $($targets.Count) agent(s) with a running process:"
$targets | Format-Table -AutoSize id, pid, state, status, name | Out-String -Width 200 | Write-Host

if ($DryRun) { Write-Host 'Dry run: nothing stopped.'; exit 0 }

if (-not $Yes) {
    $answer = Read-Host 'Stop all of them? [y/N]'
    if ($answer -notmatch '^(y|yes)$') { Write-Host 'Aborted.'; exit 0 }
}

$failed = 0
foreach ($a in $targets) {
    Write-Host -NoNewline "Stopping $($a.id) ($($a.name))... "
    & claude stop $a.id *> $null
    if ($LASTEXITCODE -eq 0) { Write-Host 'ok' -ForegroundColor Green }
    else { Write-Host "failed (exit $LASTEXITCODE)" -ForegroundColor Red; $failed++ }
}

Write-Host "Done: $($targets.Count - $failed) stopped, $failed failed."
exit [int]($failed -gt 0)
