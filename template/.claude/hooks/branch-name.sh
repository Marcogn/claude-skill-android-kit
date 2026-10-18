#!/bin/bash
# PreToolUse hook: a branch Claude creates must have a name that says what it is for.
# Generic: copy it unchanged into any project (docs/claude.md).
#
# Checks `git checkout -b|-B|--orphan`, `git switch -c|-C|--create`, `git branch <name>`,
# `git worktree add -b` (Bash; only real commands, not quoted text) and mcp__github__create_branch.
# Accepted: <type>/<what-and-where>, lowercase, hyphens, at least three words in all, e.g.
# fix/crash-on-rotation, feat/export-pdf-share, deps/gradle-minor-bumps.
# Branches named `claude/...` or `ccr-...` are the cloud environment's own and always pass, as do
# main, master, develop, gh-pages and release/x.y.z.
#
# Denies only when sure, otherwise passes (fails open). It is a guide for names, not a shell
# parser: it reads quotes ('...', "...", $'...'), heredocs, (( )) arithmetic, `; & | ( )`
# separators, redirections, `#` comments, simple prefixes (`VAR=x`, `env`, `command` without
# options) and git's global options. When the command can't be
# read with certainty (an unterminated quote or heredoc, unbalanced (( ))) or the name isn't a
# plain literal ($VAR, $( ), globs), it passes. A wrongly denied normal command is a bug to report;
# a command that passes unchecked is accepted.

set -u
INPUT=$(cat)

if command -v jq >/dev/null 2>&1; then
  TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')
  CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
  MCP=$(echo "$INPUT" | jq -r '.tool_input.branch // empty')
else
  exit 0
fi

# The name a git command in one shell segment creates, if any: `git [opts] checkout -b|-B|--orphan
# <name>`, `switch -c|-C|--create|--force-create <name>`, `branch <name>`, `worktree add ... -b|-B <name>`.
branch_in_segment() {
  local -a w
  read -ra w <<< "$1"
  local i=0
  # prefixes that run the command that follows: FOO=1, env, command, time, nohup, exec, sudo
  while [[ "${w[$i]:-}" =~ ^[A-Za-z_][A-Za-z0-9_]*= || "${w[$i]:-}" =~ ^(env|command|time|nohup|exec|sudo)$ ]]; do
    i=$((i + 1))
  done
  [ "${w[$i]:-}" = git ] || return 0
  i=$((i + 1))
  # git's global options; these take their value as the next word unless written with `=`
  while [[ "${w[$i]:-}" == -* ]]; do
    case "${w[$i]}" in
      -C|-c|--git-dir|--work-tree|--namespace|--config-env|--super-prefix) i=$((i + 2)) ;;
      *) i=$((i + 1)) ;;
    esac
  done
  local sub="${w[$i]:-}" j
  i=$((i + 1))
  case "$sub" in
    checkout|switch|worktree)
      for ((j = i; j < ${#w[@]}; j++)); do
        [ "${w[$j]}" = -- ] && break   # pathspecs follow
        case "$sub:${w[$j]}" in
          checkout:-b|checkout:-B|checkout:--orphan|switch:-c|switch:-C|switch:--create|switch:--force-create|worktree:-b|worktree:-B)
            echo "${w[$((j + 1))]:-}"; return 0 ;;
          # the same options with the value attached: --create=name, -cname, -bname
          switch:--create=*|switch:--force-create=*|checkout:--orphan=*)
            echo "${w[$j]#*=}"; return 0 ;;
          checkout:-b?*|checkout:-B?*|switch:-c?*|switch:-C?*|worktree:-b?*|worktree:-B?*)
            echo "${w[$j]:2}"; return 0 ;;
        esac
      done ;;
    branch)
      [[ -n "${w[$i]:-}" && "${w[$i]}" != -* ]] && echo "${w[$i]}" ;;
  esac
  return 0
}

NAME=""
if [ "$TOOL" = "Bash" ]; then
  # Split the command into segments (one per line): quoted text and heredoc bodies (commit
  # messages, echo) are dropped, even across lines; a quoted single word stays, it may be the
  # name. Redirections and comments are dropped. The awk ends with a \001 line when it couldn't read the
  # command with certainty. POSIX awk only: works with macOS awk too.
  SEGS=$(printf '%s\n' "$CMD" | awk '
    # (( at p is arithmetic when the inner paren it opened closes right before the outer one:
    # (( a + (b) )), not ((cd x) || true) where the inner one closes earlier
    function isarith(p,   k, d, ch, one) {
      d = 0; one = 0
      for (k = p; k <= n; k++) {
        ch = substr(text, k, 1)
        if (ch == "(") d++
        else if (ch == ")") { d--; if (d == 1 && !one) one = k; if (d == 0) return k == one + 1 }
      }
      return 0
    }
    { text = text $0 "\n" }
    END {
      n = length(text); q = ""; hd = ""; out = ""; i = 1
      while (i <= n) {
        c = substr(text, i, 1)
        if (q != "" && c == q) {
          # a quoted single word may be a branch name; longer text is one opaque argument
          # ($ kept when it expands, so a quoted "$(...)" name still counts as not literal)
          if (qb ~ /^[^ \t\n]+$/) out = out qb
          else if (q == "\"" && qb ~ /[$`]/) out = out "$_"
          else out = out "_"
          q = ""; ansi = 0; i++; continue
        }
        # backslash escapes inside "..." and inside ANSI-C $\047...\047 quotes (\\\047 does not close)
        if ((q == "\"" || ansi) && c == "\\") { qb = qb substr(text, i + 1, 1); i += 2; continue }
        if (q != "") { qb = qb c; i++; continue }
        if (c == "$" && substr(text, i + 1, 1) == "\047") { q = "\047"; ansi = 1; qb = ""; i += 2; continue }
        if (c == "\047" || c == "\"") { q = c; ansi = 0; qb = ""; i++; continue }
        if (c == "\\") { i += 2; continue }
        # a # that starts a word comments out the rest of the line
        if (c == "#" && (out == "" || substr(out, length(out), 1) ~ /[ \t\n]/)) {
          while (i <= n && substr(text, i, 1) != "\n") i++
          continue
        }
        if (substr(text, i, 2) == "((" && isarith(i)) { arith++; out = out "\n"; i += 2; continue }
        if (arith && substr(text, i, 2) == "))") { arith--; out = out "\n"; i += 2; continue }
        if (substr(text, i, 3) == "<<<") { c = "<" }   # herestring: a redirection like < below
        else if (!arith && substr(text, i, 2) == "<<") {
          j = i + 2; tabs = 0
          if (substr(text, j, 1) == "-") { tabs = 1; j++ }
          while (substr(text, j, 1) == " ") j++
          hd = ""
          while (j <= n) {
            ch = substr(text, j, 1)
            if (ch ~ /[ \t\n;&|<>()]/) break
            if (ch != "\047" && ch != "\"" && ch != "\\") hd = hd ch
            j++
          }
          i = j; continue
        }
        if (c ~ /[<>]/) {
          # a redirection: drop it with its fd (2>), operator (>>, >&, >|, <<<) and target word
          if (out ~ /(^|[ \t\n])[0-9]+$/) sub(/[0-9]+$/, "", out)   # only a whole word is an fd
          while (substr(text, i, 1) ~ /[<>&|]/) i++
          while (substr(text, i, 1) ~ /[ \t]/) i++
          qc = substr(text, i, 1)
          if (qc == "\047" || qc == "\"") {   # quoted target: skip to its closing quote
            k = index(substr(text, i + 1), qc)
            if (!k) { unsure = 1; i = n + 1 } else i += k + 1
          }
          while (i <= n && substr(text, i, 1) !~ /[ \t\n;&|()<>]/) i++
          out = out " "; continue
        }
        if (c == "\n") {
          out = out "\n"; i++
          if (hd != "") {
            found = 0
            while (i <= n) {
              e = index(substr(text, i), "\n"); line = substr(text, i, e - 1); i += e
              if (tabs) sub(/^\t+/, "", line)
              if (line == hd) { found = 1; break }
            }
            if (!found) unsure = 1
            hd = ""
          }
          continue
        }
        if (c ~ /[;&|()]/) out = out "\n"; else out = out c
        i++
      }
      printf "%s\n", out
      if (q != "" || arith || hd != "" || unsure) printf "\001\n"
    }')
  case "$SEGS" in *$'\001'*) exit 0 ;; esac
  while IFS= read -r seg; do
    [[ "$seg" == *git* ]] || continue
    seg="${seg#"${seg%%[![:space:]]*}"}"
    NAME=$(branch_in_segment "$seg")
    [ -n "$NAME" ] && break
  done <<< "$SEGS"
  # Not a plain literal (a variable, a command substitution, a glob): its value is unknown here.
  case "$NAME" in *[\$\`\(\)\{\}\*\?\[]*) exit 0 ;; esac
else
  NAME="$MCP"
fi
[ -z "$NAME" ] && exit 0
# the cloud environment's own names, and the standard base branches (e.g. `checkout -b main
# origin/main` in a single-branch clone)
case "$NAME" in claude/*|ccr-*|main|master|develop|gh-pages) exit 0 ;; esac
echo "$NAME" | grep -Eq '^release/v?[0-9]+(\.[0-9]+)*$' && exit 0

WORDS=$(echo "$NAME" | tr '/_.-' '\n\n\n\n' | grep -Ec '^[a-z]{3,}$')
if echo "$NAME" | grep -Eq '^[a-z0-9]+([/_.-][a-z0-9]+)*$' && [ "$WORDS" -ge 3 ] \
   && ! echo "$NAME" | grep -Eq '^(tmp|temp|test|wip|new|patch|branch)([/_.-]|$)'; then
  exit 0
fi

MSG="Branch name '$NAME' doesn't say what the branch is for. Use <type>/<what-and-where> in lowercase with hyphens, at least three words, e.g. fix/crash-on-rotation, feat/export-pdf-share, deps/gradle-minor-bumps, docs/ci-release-guide (types: feat, fix, refactor, docs, chore, deps, plan, phase). Rename and retry."
jq -n --arg r "$MSG" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
exit 0
