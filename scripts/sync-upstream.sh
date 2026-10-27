#!/usr/bin/env bash
# Fetch upstream into the downstream working branch; never push either remote.
set -euo pipefail
cd "$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"

if [[ "$(git branch --show-current)" != custom/thaw-3-zh ]]; then
    echo 'Switch to custom/thaw-3-zh before syncing.' >&2
    exit 1
fi
if [[ -n "$(git status --porcelain)" ]]; then
    echo 'Commit or stash local changes before syncing.' >&2
    exit 1
fi
case "$(git remote get-url origin)" in
    https://github.com/1zumiii/Thaw-Custom.git|git@github.com:1zumiii/Thaw-Custom.git) ;;
    *) echo 'origin must point to 1zumiii/Thaw-Custom.' >&2; exit 1 ;;
esac
if ! git remote get-url upstream >/dev/null 2>&1; then
    git remote add upstream https://github.com/thaw-app/Thaw.git
fi
case "$(git remote get-url upstream)" in
    https://github.com/thaw-app/Thaw.git|git@github.com:thaw-app/Thaw.git) ;;
    *) echo 'upstream must point to thaw-app/Thaw.' >&2; exit 1 ;;
esac
git remote set-url --push upstream DISABLED
git config remote.pushDefault origin
git fetch upstream development:refs/remotes/upstream/development
git merge --no-edit refs/remotes/upstream/development
python3 scripts/check-localization.py
echo 'Upstream merged locally. Review and test before pushing to origin.'
