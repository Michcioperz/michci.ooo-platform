#!/bin/sh -e
project="$1"
echo "::group::Ensuring the repository exists"
git clone "https://github.com/michcioperz/$project" --bare "$project.git" || true
echo "::endgroup::"
repo="$(realpath "$project.git")"
tmpdir="$(mktemp -d -p "$repo")"
function finish {
	echo "::group::Removing the temporary work tree"
	git -C "$repo" worktree remove "$tmpdir"
	echo "::endgroup::"
}
trap finish EXIT
echo "::group::Fetching new changes"
git -C "$repo" fetch
echo "::endgroup::"
echo "::group::Checking out HEAD"
git -C "$repo" worktree add "$tmpdir" FETCH_HEAD
echo "::endgroup::"
cd "$tmpdir"
echo "::group::Building"
result="$(nix-build --no-out-link)"
echo "::endgroup::"
echo "::group::Deploying"
nix-env --profile /nix/var/nix/profiles/per-user/nginx/michciooo -i "$result"
echo "::endgroup::"
