# Changelog

## [Unreleased]

- **`branch-name.sh`, second round.** Commands are split with POSIX awk instead of GNU-only `sed`
  (`\n` in a replacement), so it works with macOS awk/sed too; quoted text spanning several lines
  and heredoc bodies (commit messages) are skipped; `--create=name`, `-cname`, `-bname` are
  checked; a quoted single-word name (`-b "wip"`) is still checked. Found by the review in
  ThePatientGamerHelper.

- **Fixes from the first round of updates.** `branch-name.sh` lets the cloud's `ccr-…` branches
  through, looks only at real commands (no more denials for `git branch | head` or a commit message
  that mentions `git branch`), also checks `switch --create`, `checkout --orphan` and `worktree add
  -b`, and builds its JSON with `jq` (#5). `self-review` falls back to `origin/main` when the clone
  has no `origin/HEAD`, as the gate does. `next-phase` proposes out-of-scope findings as issues
  instead of notes in CLAUDE.md, as `docs/claude.md` says. Build APK and Release also print the
  certificate's SHA-1 (#3).

- **Skill `issues-triage`.** Reads the open issues (body, comments, linked PRs, whether a plan
  already assigns them), finds what each touches in the code, and proposes a resolution plan in the
  chat: size, state (ready, needs info, planned, in progress, duplicate, obsolete), sessions grouped
  by area with the model for each (Sonnet, Opus, or an Opus + Sonnet split) and the first message
  to start them. Issues too big for one PR go to `/new-plan`. Never comments, labels or closes.

- **Review before the PR, enforced.** New skill `self-review` (verify, `/code-review` and the
  `architecture-reviewer` agent in parallel, fixes, record) and hook `review-gate.sh`: a session
  that committed code can't end, and `create_pull_request` is denied, until the diff is reviewed;
  a later change makes the review stale. Docs-only diffs are exempt. `close-phase` now runs
  `self-review` as its step 3. Reason: `claude-review.yml` skips draft PRs, which cloud sessions
  open, so in projects where `/close-phase` wasn't run nothing was ever reviewed.

- **Release cleans the Actions history.** As its last step, only after the release is published and
  the bump pushed, it deletes the completed runs of every workflow except Release and the latest
  successful Build APK (needs `actions: write` in the caller; without it, it warns). A failed release
  deletes nothing, so its history is there to debug it.

- **Release version from a choice.** The dispatch form offers `bump` (minor by default, patch,
  major) computed from the current `versionName`; `version` becomes optional and overrides it.
  The reusable workflow's `version` input is no longer required (old callers keep working).

- **Dependabot: cooldown and `/deps-triage`.** Gradle updates are proposed only after a version has
  been out 3 days (patch), 7 (minor) or 14 (major), Actions after 7; security updates are not
  delayed. New skill `deps-triage`: a verdict on each open Dependabot PR (safe / to look at /
  close) with the reason; it never approves or merges.

- **Names.** Hook `branch-name.sh` refuses vague names for branches Claude creates
  (`<type>/<what-and-where>`); `next-phase` and `new-plan` name the session with `set_session_title`;
  INSTALL adds the rule to a project's `CLAUDE.md`. `docs/claude.md` "Names".

- **`architecture-reviewer` runs on Opus.** `model: opus` instead of `inherit`: phases done with
  Sonnet get a stricter review at `/close-phase`, at the cost of some extra usage.

- **Skill `new-plan`.** Plans new work as phases in the project's format: asks the decisive
  questions and which open issues to include, then proposes the plan as a draft PR "Piano: …" to
  adjust and merge; writes no code. `next-phase` treats issues the plan assigned to a phase as in
  scope. (`/plan` is a Claude Code built-in, hence the name.)

- **Android CI: `release-build-args` input.** Extra Gradle arguments for the release build only
  (KartLog's `-PofflineSeed`), instead of passing non-secret flags through `BUILD_ENV`. `INSTALL.md`
  also fixes a stale app version written in a project's `CLAUDE.md`.

## [1.0.0] - 2026-10-09

- **First version, extracted from PdfToolkit.** Reusable workflows (Android CI with optional
  coverage, Build APK, Release, cleanup, `@claude`, PR review) with explicit secrets and an optional
  `BUILD_ENV`; Claude Code kit (skills `verify`, `next-phase`, `close-phase`, `steward`, agent
  `architecture-reviewer`, Android SDK hook, settings); Dependabot, PR and issue templates; docs;
  the `android-kit` launcher skill and `INSTALL.md`.
