# claude-skill-android-kit

The shared setup of Marcogn's Android projects: what Claude Code needs to work well in each of them,
and the GitHub workflows they all run. One source, every project aligned.

| Part | Path here | In a project |
|---|---|---|
| Reusable workflows: Android CI, Build APK, Release, cleanup, `@claude`, PR review | `.github/workflows/` | short callers in `.github/workflows/`, pinned at `@v1` |
| Claude Code kit: skills (`new-plan`, `verify`, `next-phase`, `close-phase`, `steward`), `architecture-reviewer` agent, Android SDK hook, settings | `template/.claude/` | copied to `.claude/` |
| Dependabot, PR template, issue templates | `template/.github/` | copied |
| Docs: how and why (`claude.md`), workflows and secrets (`ci.md`) | `template/docs/` | copied to `docs/` |
| The `android-kit` skill (launcher for claude.ai) | `skill/android-kit/` | uploaded once to the author's claude.ai account |
| The install/update procedure the skill follows | `INSTALL.md` | — |

Start with [`template/docs/claude.md`](template/docs/claude.md) (the model behind the kit, and how a
project gets and updates it) and [`template/docs/ci.md`](template/docs/ci.md) (workflows, values,
secrets).

## Using it

1. Once: zip `skill/android-kit/` and upload it on claude.ai (skills settings, "Upload skill").
2. In a Claude Code cloud session on a project: `/android-kit`. It opens a PR that aligns the
   project with the kit; run it again later to update.

## What `/android-kit` does to a project

It opens a **draft pull request** in the project; nothing reaches `main` until you merge it. In
order (the exact procedure is [`INSTALL.md`](INSTALL.md)):

1. **Reads the project**: `CLAUDE.md`, plans, decisions, workflows, build script, docs language. On a
   project that already has the kit, says what changed in the kit since its version.
2. **Copies the generic files** from `template/`: the skills `new-plan`, `verify`, `next-phase`,
   `close-phase`, `steward`, the `architecture-reviewer` agent, the Android SDK hook and `.claude/settings.json`
   (merged with the project's own), Dependabot, PR and issue templates, `docs/claude.md`, `docs/ci.md`.
   If the project changed one of these files itself, it shows the difference and **asks**.
3. **Replaces the workflows with callers of the kit** (CI, Build APK, Release, cleanup, `@claude`, PR
   review) with the project's values: app module, JDK, forbidden permissions, coverage. It first
   compares the old workflows with the kit's and **asks** about anything the old ones did that the kit
   doesn't. Other workflows of the project are left alone.
4. **Secrets**: same names everywhere (`docs/ci.md`). Where the project uses other names it maps them
   in the callers and tells you which to rename; extra secrets the build reads go into `BUILD_ENV`.
5. **Checks what Release needs**: literal `versionCode`/`versionName`, the signing block, a
   `CHANGELOG.md` with `[Unreleased]`; adds what is missing, or asks if that would change the build.
6. **Coverage**: adds the opt-in JaCoCo line to the app module.
7. **Writes `REVIEW.md`** from the project's own rules, each one checked against the code (asks
   about rules the code contradicts).
8. **Small doc edits**: a few lines in `CLAUDE.md` (where things are, commands, the SDK hook, issues
   for bugs and ideas), the decisions file, the README; records `.claude/kit-version`. A very long
   `CLAUDE.md` isn't trimmed: it proposes that separately.
9. **Verifies**: Android SDK, lint, unit tests, debug build, coverage; workflow and file checks.
10. **Hands back** in Italian: the PR, coverage numbers, secrets to rename, open proposals. Build
    APK and Release can only be tried by running them after the merge.

It never changes app code, never touches the signing keys or secret values, and never merges.

## Changing it

- Workflows: projects call them at `@v1`, a **branch** that marks the stable version (GitHub accepts
  a branch, tag or SHA there). A change on `main` reaches every project at its next run once `v1` is
  moved to it: `git push origin main:v1` (a fast-forward). A change callers must adapt to goes to a new
  `v2` branch, and projects move to it on purpose.
- Everything under `template/`: projects get it at their next `/android-kit`.
- `skill/`: re-upload to claude.ai only when the launcher changes.
- Record each change in `CHANGELOG.md`.

The `check` workflow lints the workflows (actionlint) and validates the skills' frontmatter and the
JSON/YAML files on every push and pull request.

## Licence

MIT, see [LICENSE](LICENSE).
