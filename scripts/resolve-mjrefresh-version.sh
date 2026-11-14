#!/bin/bash
# Usage: scripts/resolve-mjrefresh-version.sh [--write <Podfile>...]
#
# Prints the latest stable version of the MJRefresh pod, read from the CocoaPods CDN (the index `pod` itself resolves
# from), so no CocoaPods install is needed. Examples always depend on this version next to CYLRefresh, which is adapted
# from MJRefresh (instructions.md, "Depending on MJRefresh in the examples"). Run it before every example build.
#
# With --write, also rewrites the version of the `pod 'MJRefresh', '<version>'` line in each given Podfile; it fails when
# a Podfile has no such line. CYL_COCOAPODS_CDN overrides the CDN (default: https://cdn.cocoapods.org).
set -euo pipefail
CDN="${CYL_COCOAPODS_CDN:-https://cdn.cocoapods.org}"
NAME=MJRefresh
WRITE=()
if [[ "${1:-}" == "--write" ]]; then
  shift
  [[ $# -gt 0 ]] || { echo "usage: $0 --write <Podfile>..." >&2; exit 2; }
  WRITE=("$@")
fi

# The CDN shards its version index by the first three hex digits of the pod name's MD5.
MD5=$(printf '%s' "$NAME" | openssl md5 | awk '{print $NF}')
SHARD="${MD5:0:1}_${MD5:1:1}_${MD5:2:1}"
INDEX=$(curl -fsSL --retry 3 --max-time 60 "$CDN/all_pods_versions_${SHARD}.txt")
LINE=$(printf '%s\n' "$INDEX" | grep "^${NAME}/" || true)
[[ -n "$LINE" ]] || { echo "error: $NAME not found in the CocoaPods index" >&2; exit 1; }
# Stable versions only (digits and dots), highest first; up to four numeric fields, such as 3.1.14.1.
VERSION=$(printf '%s\n' "${LINE#"${NAME}"/}" | tr '/' '\n' | grep -E '^[0-9]+(\.[0-9]+){0,3}$' |
  sort -t. -k1,1n -k2,2n -k3,3n -k4,4n | tail -1)
[[ -n "$VERSION" ]] || { echo "error: no stable $NAME version found" >&2; exit 1; }
echo "$VERSION"

for podfile in "${WRITE[@]+"${WRITE[@]}"}"; do
  grep -Eq "pod +'${NAME}', *'[0-9][0-9.]*'" "$podfile" ||
    { echo "error: $podfile has no pod '${NAME}', '<version>' line" >&2; exit 1; }
  sed -E -i.bak "/pod +'${NAME}'/ s/(pod +'${NAME}', *')[0-9][0-9.]*(')/\1${VERSION}\2/" "$podfile"
  rm -f "$podfile.bak"
  echo "updated $podfile" >&2
done
