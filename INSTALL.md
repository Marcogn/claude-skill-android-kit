# Installing or updating the kit in a project

Instructions for Claude, followed when the author runs `/android-kit` in a session on one of their
Android repositories (the launcher skill in `skill/` clones this repository and points here). They
also work by hand. `$KIT` is the clone of this repository; the **project** is the repository the
session was started on.

Goal: the project ends up aligned with the kit, working the same as the others, with only its own
values different. Be conservative with anything that decides how the app is built, signed or
released: change it only as described here, and list every behaviour difference in the PR.

## 0. Look at the project

- An Android Gradle project: `settings.gradle(.kts)` and an application module (from `include(...)`
  and the module applying `com.android.application`; usually `app`).
- Read `CLAUDE.md` (and what it points to), `README.md`, the decisions file and ADRs if any,
  `CHANGELOG.md`, `.github/workflows/`, the app module's build script. Note the docs' language:
  per-project text is written in that language.
- Kit version: `git -C "$KIT" rev-parse --short HEAD`. If `.claude/kit-version` exists this is an
  **update**: `git -C "$KIT" fetch --unshallow` and `git -C "$KIT" log --oneline <old>..HEAD` say what
  changed; tell the author in two or three lines before touching anything.
- Branch: the one the environment gives, else `android-kit`.

## 1. Generic files: copy `template/` unchanged

Every file under `$KIT/template/` goes to the same path in the project, except the workflows (step 3)
and `.claude/settings.json` (below).

- A project file that exists and differs from the kit **and** from the previous kit version (a local
  change made in the project): don't overwrite silently. Show the diff and ask (AskUserQuestion:
  keep the project's, take the kit's, merge). A local improvement that would help every project
  belongs in the kit: offer to open an issue in the kit repository for it.
- `.claude/settings.json`: if absent, copy it. If present, merge: the kit's `SessionStart` hook and
  permission rules, plus every other key the project has.
- Keep `.claude/hooks/android-sdk.sh` executable. Add `.claude/settings.local.json` to `.gitignore`.
- Old copies of the kit's own launcher or of an earlier kit skill inside the project (e.g.
  `tools/claude-kit/`) are removed.

## 2. Per-project values

Collect them from the project's current workflows and build:

- `app-module`, `java-version` (from `compileOptions`/`jvmToolchain`/the old workflow);
- `forbidden-permissions` (from the old CI, or a rule in CLAUDE.md/spec such as "no INTERNET");
- signing secret names used today (from the old workflows). The standard names are in
  `template/docs/ci.md`; where the project uses others, map them in the callers
  (`RELEASE_KEYSTORE_BASE64: ${{ secrets.ANDROID_KEYSTORE_BASE64 }}`) and tell the author which
  secrets to rename later so the mapping can go;
- environment variables the build reads from secrets (an old workflow passing
  `SOME_ID: ${{ secrets.SOME_ID }}` to Gradle): they go into `BUILD_ENV` in the callers that build
  (`BUILD_ENV: "SOME_ID=${{ secrets.SOME_ID }}"`). `BUILD_ENV` is for secret values only;
- extra Gradle arguments the old CI passed to its release build (e.g. `RELEASE_BUILD_ARGS:
  -PofflineSeed`): `release-build-args` in the Android CI caller. If the old workflows passed Gradle
  arguments the kit has no input for, list them and ask: the fix belongs in the kit (an issue there),
  not in a workaround through `BUILD_ENV`.

## 3. Workflows: callers of the kit

Replace `android-ci.yml`, `build-apk.yml`, `release.yml`, `cleanup-runs.yml`, `claude.yml`,
`claude-review.yml` in the project's `.github/workflows/` with the callers from
`$KIT/template/.github/workflows/`, filled with the values of step 2.

Before replacing, compare each old workflow with the kit's reusable one
(`$KIT/.github/workflows/<name>.yml`): triggers, steps, outputs (artifact and asset names), secrets.
- Same behaviour, or the old one is an earlier copy of the kit's: replace.
- The old one does something the kit doesn't (an extra step, another trigger, a different asset
  name someone may rely on): list it, and ask the author whether to drop it, keep it as an extra
  workflow in the project, or bring it into the kit (an issue in the kit repository).
- Other workflows of the project that aren't the kit's: leave them.

The release relies on the app module having `versionCode = N` and `versionName = "x.y.z"` as plain
literals, the signing block of `template/docs/ci.md`, and `CHANGELOG.md` with a `## [Unreleased]`
section. Check all three; if one is missing, add it (the signing block exactly as in `docs/ci.md`)
or, if that would change how the project is built today, ask.

## 4. Coverage

In the app module's build script, inside `buildTypes`, add (creating `debug { }` if missing):

```kotlin
debug {
    // JaCoCo coverage of the JVM unit tests, only when asked (`-Pcoverage`), since it slows
    // the tests: `./gradlew testDebugUnitTest createDebugUnitTestCoverageReport -Pcoverage`.
    enableUnitTestCoverage = providers.gradleProperty("coverage").isPresent
}
```

and keep `coverage: true` in the Android CI caller.

## 5. Per-project files

- **`REVIEW.md`** at the root (create, or on an update keep it and only check it still matches the
  code). Sections: `What Important means here`, `Always check`, `Verification bar`, `Do not
  report`, `Shape`; in the docs' language; at most ~50 lines. "Always check" comes from the project's
  own rules (CLAUDE.md rules and conventions, ADRs, decisions). **Verify each rule against the code
  first** (Grep: where the class or package really is, which imports really occur); a rule the code
  contradicts is wrong in the docs or is a finding: ask, don't write it.
- **`CLAUDE.md`**: minimal edits in its language and style, no rewrite:
  - where things are: one line for `.claude/` (kit skills, reviewer agent, SDK hook; from
    claude-skill-android-kit, `docs/claude.md`) and one for the workflows (callers of the kit,
    `docs/ci.md`);
  - commands: the coverage command;
  - manual Android SDK steps for cloud sessions: replace with a pointer to the hook;
  - a session protocol that sends out-of-scope findings to CLAUDE.md notes: align it (bugs and ideas
    become GitHub issues, `docs/claude.md`, "Issues");
  - a version of the app written in prose (e.g. "App alla 1.1.2") that differs from the build's
    `versionName`: it is stale (Release bumps the build and the CHANGELOG, not CLAUDE.md). Replace it
    with a pointer to the build and the CHANGELOG, so it can't go stale again;
  - over ~300 lines: don't trim here; say in the PR that it is read on every turn and propose
    trimming it as a separate task.
- The decisions file, if any: one dated entry (kit adopted or updated, version, what was adapted,
  what was left out).
- `README.md`: in its documentation list, if it has one, lines for `docs/claude.md` and `docs/ci.md`.
- `.claude/kit-version`: `<kit short sha> <date>`, one line.
- No `CHANGELOG.md` entry: nothing user-visible changes.

## 6. Verify

```bash
CLAUDE_CODE_REMOTE=true CLAUDE_PROJECT_DIR="$PWD" bash .claude/hooks/android-sdk.sh
LC_ALL=C.UTF-8 ./gradlew lintDebug testDebugUnitTest assembleDebug --console=plain
LC_ALL=C.UTF-8 ./gradlew testDebugUnitTest createDebugUnitTestCoverageReport -Pcoverage --console=plain
```

In the background. Network failures (plugin not found, `Could not resolve`/`Could not GET`, 429) are
normal on a cold Gradle cache: retry up to ~10 times, 15 s apart, stopping at the first other error.
A failure the kit didn't cause (red before the change too): report it, don't fix it here. Note the
test count and the coverage (overall, and the weakest packages).

Also: JSON/YAML parse, skill and agent frontmatter parse, and `actionlint` on the workflows if it can
be downloaded (github.com/rhysd/actionlint releases). The PR's own CI then runs Android CI through
the kit: it must be green.

## 7. Commit, PR, hand back

- One commit `Android kit <short sha>` (plus the attribution lines the session asks for), push,
  **draft** PR filled with the copied template: what was copied, values and secret mappings, what
  differed in the old workflows and what was decided, verification and coverage numbers. Subscribe
  to the PR.
- Reply to the author in Italian, in a few lines: the PR, coverage numbers, secrets to rename (if
  any), open proposals (CLAUDE.md trimming, kit issues). Remind them that Build APK and Release can
  only be tried by running them (Actions tab), and that the cloud environment setup script and the
  optional `CLAUDE_CODE_OAUTH_TOKEN` secret are described in `docs/claude.md`.
