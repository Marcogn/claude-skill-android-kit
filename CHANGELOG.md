# Changelog

## [Unreleased]

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
