# Changelog

## [Unreleased]

- **Android CI: `release-build-args` input.** Extra Gradle arguments for the release build only
  (KartLog's `-PofflineSeed`), instead of passing non-secret flags through `BUILD_ENV`. `INSTALL.md`
  also fixes a stale app version written in a project's `CLAUDE.md`.

## [1.0.0] - 2026-10-09

- **First version, extracted from PdfToolkit.** Reusable workflows (Android CI with optional
  coverage, Build APK, Release, cleanup, `@claude`, PR review) with explicit secrets and an optional
  `BUILD_ENV`; Claude Code kit (skills `verify`, `next-phase`, `close-phase`, `steward`, agent
  `architecture-reviewer`, Android SDK hook, settings); Dependabot, PR and issue templates; docs;
  the `android-kit` launcher skill and `INSTALL.md`.
