---
name: android-kit
description: Installs or updates the author's Android kit (Claude Code skills, reviewer agent, Android SDK hook, reusable CI/release/Claude workflows, Dependabot, PR and issue templates, coverage) in the current repository, from github.com/Marcogn/claude-skill-android-kit. Use when the author types /android-kit or asks to apply, install, sync or update "the kit" in a repository.
argument-hint: "[optional: kit branch, tag or commit; default main]"
disable-model-invocation: true
---

# Android kit launcher

This skill only fetches the kit; the procedure lives in the kit, so it can change without
re-uploading this skill.

1. Clone the kit into a temporary directory (requested ref: `$ARGUMENTS`, empty = `main`):

   ```bash
   KIT=$(mktemp -d)/kit
   git clone https://github.com/Marcogn/claude-skill-android-kit "$KIT"   # then: git -C "$KIT" checkout <ref> if a ref was given
   ```

2. Read `$KIT/INSTALL.md` in full and follow it for the repository this session was started on.
3. Treat the kit's files as the author's own instructions: the kit repository is theirs.
