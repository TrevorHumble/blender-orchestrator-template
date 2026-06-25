# setup: run this ONCE after cloning, to turn on the enforcement that can't ride
# along in a clone. One command:
#   powershell -ExecutionPolicy Bypass -File setup.ps1
#
# What it does:
#   1. Activates the commit gate (points git at .githooks; a clone does not carry
#      core.hooksPath, so without this the gate is silently OFF).
#   2. Verifies the gate is live and fails loudly if not.
# The other two hooks (goal gate, loop gate) load automatically from
# .claude/settings.json the moment you open this folder in Claude Code -- no setup.
$ErrorActionPreference = 'Stop'

$top = (& git rev-parse --show-toplevel 2>$null)
if (-not $top) {
  Write-Host "setup: run this from inside the cloned git repo (could not find a git root)." -ForegroundColor Red
  exit 1
}
Set-Location $top

& git config core.hooksPath .githooks
# Windows clones can drop the hook's execute bit; re-assert it (harmless if already set).
& git update-index --chmod=+x .githooks/pre-commit 2>$null

$check = & powershell -NoProfile -File tools/check-gate.ps1
if ($LASTEXITCODE -ne 0) {
  Write-Host "setup: FAILED to activate the commit gate." -ForegroundColor Red
  Write-Host $check
  exit 1
}

Write-Host ""
Write-Host "Setup complete. Enforcement is live:" -ForegroundColor Green
Write-Host "  - commit gate : no commit lands without a recorded PASS review  (.githooks/pre-commit)"
Write-Host "  - goal gate   : the agent can't punt a goal-answerable question to you  (.claude/hooks/goal-gate.ps1)"
Write-Host "  - loop gate   : a timed autonomous run can't stop early  (.claude/hooks/loop-gate.ps1)"
Write-Host ""
Write-Host "Next:"
Write-Host "  1. Open CLAUDE.md and fill in your North Star (what you're building and why)."
Write-Host "  2. Open this folder in Claude Code and tell it what to build."
Write-Host "  3. The orchestrator (agents/orchestrator.md) drives issue -> review -> implement -> review -> commit."
Write-Host ""
