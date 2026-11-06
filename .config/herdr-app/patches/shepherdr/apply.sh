#!/bin/sh
# Re-apply the local Shepherdr mod patches in this folder, in filename order.
# See README.md beside this script.

set -u

usage() {
	cat <<'EOF'
Usage: apply.sh [--check] [--mods DIR] [--help]

Applies each *.patch beside this script (in filename order) to the Herdr
mods folder with `patch -p1`. A patch that is already in is reported as
"already applied" and skipped. A patch that neither applies cleanly nor is
already in stops the run with its rejected hunks and exit status 1.

  --check      Dry run: report each patch's state, change nothing (it
               works on a scratch copy, so later patches are checked with
               the earlier ones in place). Exits 1 if any patch would fail.
  --mods DIR   Mods folder to patch (default: $HERDR_APP_HOME/mods,
               or ~/.config/herdr-app/mods).
  --help       Show this help.

Herdr hot-reloads mods, so no restart is needed after applying.
EOF
}

check=0
mods=
while [ $# -gt 0 ]; do
	case $1 in
		--check) check=1 ;;
		--mods)
			[ $# -ge 2 ] || { echo "apply.sh: --mods needs a directory" >&2; exit 2; }
			mods=$2; shift ;;
		--mods=*) mods=${1#--mods=} ;;
		-h|--help) usage; exit 0 ;;
		*) echo "apply.sh: unknown option: $1" >&2; usage >&2; exit 2 ;;
	esac
	shift
done

here=$(cd "$(dirname "$0")" && pwd) || exit 1
[ -n "$mods" ] || mods="${HERDR_APP_HOME:-$HOME/.config/herdr-app}/mods"
[ -d "$mods" ] || { echo "apply.sh: mods folder not found: $mods" >&2; exit 2; }

# -N: never treat a patch as reversed and undo it; -t: never ask questions;
# -V none: no .orig backups. No --force, no extra fuzz. Questions would read
# from stdin, so it is /dev/null.
run_patch() {
	patch -d "$mods" -p1 -N -t -V none "$@" </dev/null
}

set -- "$here"/*.patch
[ -e "$1" ] || { echo "apply.sh: no *.patch files in $here" >&2; exit 2; }

echo "mods: $mods"

# Scratch space outside the mods folder: rejects go here, never beside a mod file.
scratch=$(mktemp -d "${TMPDIR:-/tmp}/shepherdr-patches.XXXXXX") || exit 1
trap 'rm -rf "$scratch"' EXIT
trap 'exit 130' INT TERM

# Print the hunks of $1 that don't apply. patch writes its output (-o) and
# rejects (-r) into scratch, so the mods folder is not touched.
show_rejects() {
	rm -f "$scratch/out" "$scratch/rej"
	run_patch -o "$scratch/out" -r "$scratch/rej" -i "$1" 2>&1 | grep -v -e '^done$' -e 'saving rejects to'
	[ -s "$scratch/rej" ] && { echo "--- rejected hunks:"; cat "$scratch/rej"; }
}

# --check works on a scratch copy of the mod folders the patches touch, so
# each later patch is checked as if the earlier ones were applied.
if [ $check -eq 1 ]; then
	mkdir "$scratch/mods" || exit 1
	for d in $(sed -n 's|^+++ b/\([^/]*\)/.*|\1|p' "$@" | sort -u); do
		[ -d "$mods/$d" ] && cp -Rp "$mods/$d" "$scratch/mods/"
	done
	mods=$scratch/mods
fi

failed=0
for p in "$@"; do
	name=$(basename "$p")
	if out=$(run_patch --dry-run -i "$p" 2>&1); then
		if out=$(run_patch -i "$p" 2>&1); then
			if [ $check -eq 1 ]; then
				echo "would apply       $name"
			else
				echo "applied           $name"
			fi
		else
			echo "FAILED            $name" >&2
			printf '%s\n' "$out" | sed 's/^/    /' >&2
			exit 1
		fi
	elif run_patch -R --dry-run -i "$p" >/dev/null 2>&1; then
		echo "already applied   $name"
	else
		echo "DOES NOT APPLY    $name" >&2
		echo "    (not cleanly, and not already in)" >&2
		show_rejects "$p" | sed 's/^/    /' >&2
		failed=1
		[ $check -eq 1 ] || {
			echo "Stopped. Patches after $name were not tried." >&2
			exit 1
		}
	fi
done
exit $failed
