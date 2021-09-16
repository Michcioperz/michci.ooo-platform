#!/bin/sh -ex
project="$1"
git clone "https://github.com/michcioperz/$project" --bare "$project.git" || true
repo="$(realpath "$project.git")"
tmpdir="$(mktemp -d -p "$repo")"
function finish {
	git -C "$repo" worktree remove "$tmpdir"
	rmdir "$tmpdir" || true
}
trap finish EXIT
git -C "$repo" fetch
git -C "$repo" worktree add "$tmpdir" FETCH_HEAD
cd "$tmpdir"
result="$(nix-build --no-out-link)"
nix-env --profile /nix/var/nix/profiles/per-user/nginx/michciooo -i "$result"
