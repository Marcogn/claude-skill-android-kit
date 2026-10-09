# claude-skill-android-kit

The shared setup of Marcogn's Android projects: what Claude Code needs to work well in each of them,
and the GitHub workflows they all run. One source, every project aligned.

| Part | Path here | In a project |
|---|---|---|
| Reusable workflows: Android CI, Build APK, Release, cleanup, `@claude`, PR review | `.github/workflows/` | short callers in `.github/workflows/`, pinned at `@v1` |
| Claude Code kit: skills (`verify`, `next-phase`, `close-phase`, `steward`), `architecture-reviewer` agent, Android SDK hook, settings | `template/.claude/` | copied to `.claude/` |
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

## Changing it

- Workflows: a change to `.github/workflows/` reaches every project at its next run once `v1` points
  to it (`git tag -f v1 && git push -f origin v1` after merging). A change that callers must adapt
  to is `v2`.
- Everything under `template/`: projects get it at their next `/android-kit`.
- `skill/`: re-upload to claude.ai only when the launcher changes.
- Record each change in `CHANGELOG.md`.

The `check` workflow lints the workflows (actionlint) and validates the skills' frontmatter and the
JSON/YAML files on every push and pull request.

## Licence

MIT, see [LICENSE](LICENSE).
