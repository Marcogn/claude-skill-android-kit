# Changelog

## [Unreleased]

- **Review before the PR, enforced.** New skill `self-review` (verify, `/code-review` and the
  `architecture-reviewer` agent in parallel, fixes, record) and hook `review-gate.sh`: a session
  that committed code can't end, and `create_pull_request` is denied, until the diff is reviewed;
  a later change makes the review stale. Docs-only diffs are exempt. `close-phase` now runs
  `self-review` as its step 3. Reason: `claude-review.yml` skips draft PRs, which cloud sessions
  open, so in projects where `/close-phase` wasn't run nothing was ever reviewed.

- **Release cleans the Actions history first.** Before anything else it deletes the completed runs
  of every workflow except Release and the latest successful Build APK (needs `actions: write` in
  the caller; without it, it warns and releases anyway).

- **Release version from a choice.** The dispatch form offers `bump` (minor by default, patch,
  major) computed from the current `versionName`; `version` becomes optional and overrides it.
  The reusable workflow's `version` input is no longer required (old callers keep working).

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
