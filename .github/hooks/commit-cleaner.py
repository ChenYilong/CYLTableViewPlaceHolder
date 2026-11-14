#!/usr/bin/env python3
"""commit-cleaner 0.1.0 - generated, do not edit.

Regenerate with `python3 install.py --upgrade`.
Source of truth: plugins/commit-cleaner/patterns.py
"""
import os
import re
import subprocess
import sys



# ---- patterns.py -------------------------------------------------

"""The attribution pattern set. Single source of truth for every component.

Each pattern is matched against a whole line with re.search, case-insensitively.
Co-Authored-By keys on the ANTHROPIC EMAIL, not the display name: a human
co-author named Claude must survive.
"""
import re
import sys
from typing import Optional  # noqa: F401

DEFAULT_PATTERNS = [
    r"^\s*Co-Authored-By:.*@anthropic\.com\s*>?\s*$",
    r"^\s*Claude-Session:\s*\S+\s*$",
    r"^\s*\S*-?Session:\s*https?://claude\.ai/code/session_\S+\s*$",
    r"^\s*\U0001f916?\s*Generated with \[Claude Code\]\(https?://[^)]*\)\s*$",
    r"^\s*\U0001f916?\s*Generated with Claude Code\s*$",
]

# Opt-in. Uncomment in a commitcleaner.patterns file rather than editing this.
#   ^\s*Co-Authored-By:.*@cursor\.com\s*>?\s*$
#   ^\s*Co-Authored-By:.*\bcodex\b.*$
#   ^\s*Co-Authored-By:.*\bcopilot\b.*$
#   ^\s*Co-Authored-By:.*\baider\b.*$
#   ^\s*Co-Authored-By:.*\bdevin\b.*$


def compile_patterns(extra=None, use_defaults=True):
    # type: (Optional[list[str]], bool) -> list[re.Pattern[str]]
    """Compile the active pattern set. A pattern that will not compile is
    skipped with a note on stderr: a bad user regex must never fail a commit."""
    sources = list(DEFAULT_PATTERNS) if use_defaults else []
    sources.extend(extra or [])
    out = []
    for src in sources:
        try:
            out.append(re.compile(src, re.IGNORECASE))
        except re.error as exc:
            print(f"commit-cleaner: skipping bad pattern {src!r} ({exc})", file=sys.stderr)
    return out


# ---- clean.py ----------------------------------------------------

"""The stripping function. Pure: no I/O, no config, no git."""
import re  # noqa: F401


def clean(text, patterns):
    # type: (str, list[re.Pattern[str]]) -> str
    """Delete every line matching any pattern, then collapse the trailing blank
    lines the deletions leave behind.

    Returns the ORIGINAL text unchanged if stripping would empty it: git aborts
    a commit whose message is empty, and this tool never blocks a commit.
    """
    if not text:
        return text

    kept = [ln for ln in text.splitlines() if not any(p.search(ln) for p in patterns)]
    while kept and not kept[-1].strip():
        kept.pop()

    if not kept:
        return text

    result = "\n".join(kept) + "\n"
    return text if not result.strip() else result


# ---- gitconfig.py ------------------------------------------------

"""Configuration comes from `git config`, never from the environment.

A git hook does not inherit the Claude Code session environment, so an env var
would make the same repo strip differently depending on who typed the command.
"""
import os
import subprocess
from re import Pattern  # noqa: F401
from typing import Optional  # noqa: F401



def _git_config(key, cwd):
    # type: (str, Optional[str]) -> Optional[str]
    try:
        out = subprocess.run(
            ["git", "config", "--get", key],
            cwd=cwd or os.getcwd(),
            capture_output=True,
            text=True,
            timeout=5,
        )
    except Exception:
        return None
    value = out.stdout.strip()
    return value if out.returncode == 0 and value else None


def _read_pattern_file(path):
    # type: (str) -> list[str]
    try:
        with open(path, encoding="utf-8") as fh:
            lines = fh.read().splitlines()
    except Exception:
        return []
    return [ln.strip() for ln in lines if ln.strip() and not ln.lstrip().startswith("#")]


def load_patterns(cwd=None):
    # type: (Optional[str]) -> list[Pattern[str]]
    """Never raises. Any failure degrades to the built-in defaults."""
    try:
        extra_path = _git_config("commitcleaner.patterns", cwd)
        extra = _read_pattern_file(extra_path) if extra_path else []
        use_defaults = _git_config("commitcleaner.defaults", cwd) != "false"
        if not extra and not use_defaults:
            use_defaults = True  # never end up with an empty pattern set
        return compile_patterns(extra=extra, use_defaults=use_defaults)
    except Exception:
        return compile_patterns()


# ---- entry point -----------------------------------------------------------
def main(argv):
    # A catastrophically backtracking user pattern must cost 5 seconds, not the
    # commit. git applies no hook timeout, and timeout(1) is absent on macOS.
    try:
        import signal

        def _bail(signum, frame):
            raise SystemExit(0)

        signal.signal(signal.SIGALRM, _bail)
        signal.alarm(5)
    except Exception:
        pass

    if len(argv) < 2:
        return 0
    path = argv[1]
    try:
        with open(path, "r", encoding="utf-8") as fh:
            original = fh.read()
        result = clean(original, load_patterns(os.getcwd()))
        if result != original:
            with open(path, "w", encoding="utf-8") as fh:
                fh.write(result)
    except Exception:
        return 0
    return 0


if __name__ == "__main__":
    import sys

    raise SystemExit(main(sys.argv))
