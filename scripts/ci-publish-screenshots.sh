#!/bin/bash
# Usage: scripts/ci-publish-screenshots.sh <folder with <scheme>.png files>
#
# Makes the example screenshots visible without downloading artifacts (instructions.md, "CI example screenshots"):
# commits them to the `ci-screenshots` branch under <pr-N or branch name>/ (replacing that folder's previous
# screenshots), then shows them inline in the job summary and in one pull request comment that is updated in place.
# When the token cannot push (a pull request from a fork), it only links the artifacts.
# Needs GITHUB_TOKEN, GITHUB_REPOSITORY, GITHUB_RUN_ID, GITHUB_SERVER_URL, GITHUB_STEP_SUMMARY; PR_NUMBER and HEAD_SHA for pull requests.
set -euo pipefail
SOURCE=$(cd "${1:?usage: scripts/ci-publish-screenshots.sh <folder>}" && pwd)
BRANCH=ci-screenshots
MARKER="<!-- cyl-example-screenshots -->"
RUN_URL="$GITHUB_SERVER_URL/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID"
if [[ -n "${PR_NUMBER:-}" ]]; then FOLDER="pr-$PR_NUMBER"; else FOLDER="${GITHUB_REF_NAME:-manual}"; fi
FOLDER=${FOLDER//\//-}
# The pull request's head commit; GITHUB_SHA is the temporary merge commit on pull_request runs.
HEAD=${HEAD_SHA:-${GITHUB_SHA:-unknown}}

mapfile -t SHOTS < <(find "$SOURCE" -maxdepth 1 -name "*.png" -size +0 -exec basename {} \; | sort)
echo "Found ${#SHOTS[@]} screenshot(s): ${SHOTS[*]:-none}"

publish() {
  local work attempt
  work=$(mktemp -d)
  git -C "$work" init -q
  git -C "$work" config user.name "github-actions[bot]"
  git -C "$work" config user.email "41898282+github-actions[bot]@users.noreply.github.com"
  git -C "$work" remote add origin "https://x-access-token:$GITHUB_TOKEN@github.com/$GITHUB_REPOSITORY.git"
  for attempt in 1 2 3 4; do
    if git -C "$work" fetch -q --depth 1 origin "$BRANCH" 2>/dev/null; then
      git -C "$work" checkout -q -B "$BRANCH" FETCH_HEAD
    else
      git -C "$work" checkout -q --orphan "$BRANCH"
      git -C "$work" rm -rq --cached . 2>/dev/null || true
      printf '# CI example screenshots\n\nWritten by scripts/ci-publish-screenshots.sh; one folder per pull request or branch.\n' \
        > "$work/README.md"
    fi
    rm -rf "${work:?}/$FOLDER"
    mkdir -p "$work/$FOLDER"
    cp "$SOURCE"/*.png "$work/$FOLDER/"
    git -C "$work" add -A
    git -C "$work" commit -q -m "Screenshots of $FOLDER from run $GITHUB_RUN_ID" || true
    if git -C "$work" push -q origin "$BRANCH" 2>/dev/null; then
      git -C "$work" rev-parse HEAD
      return 0
    fi
    echo "Push attempt $attempt was rejected; retrying on the new branch head" >&2
    sleep $((attempt * 2))
  done
  return 1
}

SHA=""
if [[ ${#SHOTS[@]} -gt 0 ]]; then
  SHA=$(publish) || { echo "warning: could not push to $BRANCH (read-only token?); linking the artifacts only" >&2; SHA=""; }
fi

BODY="$MARKER"$'\n'"### Example screenshots"$'\n\n'
if [[ ${#SHOTS[@]} -eq 0 ]]; then
  BODY+="No screenshot was produced; see the Demo jobs of [this run]($RUN_URL)."$'\n'
elif [[ -z "$SHA" ]]; then
  BODY+="Screenshots: ${SHOTS[*]}. Download the \`example-screenshot-*\` artifacts from [this run]($RUN_URL)."$'\n'
else
  BODY+="| $(printf '%s | ' "${SHOTS[@]%.png}")"$'\n'"|$(printf ':---:|%.0s' "${SHOTS[@]}")"$'\n'"| "
  for shot in "${SHOTS[@]}"; do
    BODY+="<img src=\"https://raw.githubusercontent.com/$GITHUB_REPOSITORY/$SHA/$FOLDER/$shot\" width=\"180\" alt=\"${shot%.png}\"> | "
  done
  BODY+=$'\n\n'"From [run $GITHUB_RUN_ID]($RUN_URL), commit ${HEAD:0:7}. Full size: the \`example-screenshot-*\` artifacts."$'\n'
fi
printf '%s' "$BODY" >> "$GITHUB_STEP_SUMMARY"

# One comment per pull request, updated in place; skipped without a pull request or with a read-only token.
if [[ -n "${PR_NUMBER:-}" && -n "$SHA" ]]; then
  existing=$(gh api "repos/$GITHUB_REPOSITORY/issues/$PR_NUMBER/comments" --paginate \
    --jq ".[] | select(.body | startswith(\"$MARKER\")) | .id" | head -1) || existing=""
  if [[ -n "$existing" ]]; then
    gh api -X PATCH "repos/$GITHUB_REPOSITORY/issues/comments/$existing" -f body="$BODY" >/dev/null || echo "warning: could not update the comment" >&2
  else
    gh api "repos/$GITHUB_REPOSITORY/issues/$PR_NUMBER/comments" -f body="$BODY" >/dev/null || echo "warning: could not comment" >&2
  fi
fi
