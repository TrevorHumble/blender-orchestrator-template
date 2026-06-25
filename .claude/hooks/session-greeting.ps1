# session-greeting: a SessionStart hook. The very fact this runs means the
# project's Claude-side hooks (goal gate + loop gate) loaded -- so it gives the
# owner POSITIVE confirmation they're protected, not just absence of an error. It
# also nudges to run setup.ps1 if the commit gate isn't active in this clone yet.
# Fail-safe: any error -> no greeting (harmless).
try {
  $top = (& git rev-parse --show-toplevel 2>$null)
  $commitOn = $false
  if ($top) {
    $hp = "$(& git -C $top config --get core.hooksPath)".Trim()
    $commitOn = ($hp -eq '.githooks') -and (Test-Path (Join-Path $top '.githooks/pre-commit'))
  }
  if ($commitOn) {
    $msg = "Gates armed: goal gate + loop gate loaded, commit gate active. You're protected -- direct away. (Re-check anytime: tools/check-enforcement.ps1)"
  } else {
    $msg = "Gates armed: goal gate + loop gate loaded. The commit gate is NOT active yet -- run once: powershell -ExecutionPolicy Bypass -File setup.ps1"
  }
  Write-Output (@{ systemMessage = $msg } | ConvertTo-Json -Compress)
} catch {
  exit 0
}
