# Self-Enforcing Orchestrator — project template

Clone this and you have a project where an AI orchestrator builds your software through an adversarial review pipeline **you don't have to police** — the enforcement is baked into the repo, not left to the agent's good behavior.

No human reads code in the critical path. Reviewer agents are the gate. Three hooks make the rules mechanical, not optional. You direct; the system builds and checks itself.

---

## Start a new project (3 steps)

```powershell
# 1. Make your own repo from this template (clones it down for you)
gh repo create my-project --template TrevorHumble/blender-orchestrator-template --public --clone
cd my-project

# 2. Turn on enforcement (once)
powershell -ExecutionPolicy Bypass -File setup.ps1

# 3. Open the folder in Claude Code and tell it what to build.
```

That's it. Before your first build, open **[CLAUDE.md](CLAUDE.md)** and fill in your **North Star** (what you're building and why) — every decision the agent makes flows from it.

> **Public vs private:** the commands above make a **public** repo, because GitHub's free CodeQL security scan only runs on public repos under GitHub Pro. If you'd rather keep it private, swap `--public` for `--private` — everything still works *except* CodeQL (the tests, the commit gate, and Dependabot are unaffected).
>
> **If a hook doesn't seem to fire:** close and reopen the folder in Claude Code once — hooks load at session start.

---

## What's already wired in

**Three enforcement hooks** (the part that makes "trust without checking" real):

| Hook | What it forces | Lives in |
|---|---|---|
| **Commit gate** | No commit lands unless a review verdict says PASS for exactly that code. | `.githooks/pre-commit` |
| **Goal gate** | The agent can't punt a question to you that your goals already answer. | `.claude/hooks/goal-gate.ps1` |
| **Loop gate** | A timed autonomous run can't quit early — it works the full budget. | `.claude/hooks/loop-gate.ps1` |

**The build pipeline** — `issue → review → implement → review → commit`, driven by the orchestrator (`agents/orchestrator.md`), gated by adversarial reviewer agents (`agents/reviewer-*.md`). System-level changes need two independent reviewers.

**CI/CD on every push** (`.github/workflows/`) — tests + a mutation/tamper gate that proves the tests catch broken work, GitHub CodeQL security scanning, and Dependabot. All free on a public repo within GitHub Pro.

**Doc stubs you fill in** — `CLAUDE.md` (operating rules + your North Star), `DESIGN.md`, `PLAN.md`, `BUILDLOG.md`.

**A worked example** — `addons/` ships two small Blender add-ons with full tests so CI is green the moment you clone. Delete them (and their `tests/`/`evals/`) when you start your own work; they're there to prove the whole pipeline runs end-to-end.

---

## Run it autonomously

```powershell
powershell -File tools/start-run.ps1 -Minutes 120   # arm a timed run; the loop gate blocks early stops
powershell -File tools/stop-run.ps1                  # emergency brake (or create .run_state/STOP)
```

---

## Repo layout

| Path | Purpose |
|---|---|
| `CLAUDE.md` | Operating rules loaded every session — **edit the North Star first** |
| `agents/` | Orchestrator, implementation agent, reviewers, severity adjudicator, researcher |
| `skills/` | Orchestrator actions (issue-create, spawn-adversarial-review, github-write, …) |
| `standards/` | Authoring + review standards (adversarial protocol, design-philosophy, …) |
| `.githooks/` | The commit gate (`pre-commit`) |
| `.claude/` | Hooks (goal gate, loop gate), settings, the `/build` command |
| `tools/` | `setup-hooks`, `check-gate`, `review_verdict`, `start-run`, `stop-run` |
| `tests/` · `evals/` | Dependency-free test + eval harness (with the example add-ons) |
| `.github/workflows/` | CI (`ci.yml`) + CodeQL (`codeql.yml`) |
| `DESIGN.md` · `PLAN.md` · `BUILDLOG.md` | Design rationale · build plan · running log |

Full design rationale: **[DESIGN.md](DESIGN.md)**. Plain-language "what a green build proves": **[WHAT-IT-CHECKS.md](WHAT-IT-CHECKS.md)**.
