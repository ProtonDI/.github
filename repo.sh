#!/bin/bash

#
# Bootstrapping a new repo
#

set -euo pipefail
shopt -s nullglob
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

ACTION="$1"
shift

create() {
    REPO="$1"
    DESCRIPTION="$2"

    pushd "$SCRIPT_DIR/.."
    gh repo delete --confirm "ProtonDI/$REPO" || true
    gh repo create --public "ProtonDI/$REPO"
    gh repo clone "ProtonDI/$REPO"

    cp -r "$SCRIPT_DIR/project/." "$SCRIPT_DIR/../$REPO"
    cat << EOF >> "$SCRIPT_DIR/../$REPO/README.md"
# $REPO

$DESCRIPTION
EOF
    popd
}

push() {
    REPO="$1"

    pushd "$SCRIPT_DIR/../$REPO"
    git add .
    git commit -m "Initial commit"
    git push
    gh workflow run release.yml
    popd
}

case $ACTION in
    create|push)
        $ACTION "$@"
        ;;
    *)
        echo "Unknown action `$ACTION`." >&2
        exit 1
        ;;
esac
