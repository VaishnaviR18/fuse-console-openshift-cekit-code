#!/bin/bash

set -o pipefail
set -eu

PREV_VERSION=`sed -n '/^ENV/,/^$/s/\(.*HAWTIO_ONLINE_VERSION\)\([ =]\)\([0-9a-zA-Z\.-]\+\)\(.*\)/\3/p' Dockerfile`
CURRENT_VERSION=
SCM_URL=https://code.engineering.redhat.com/gerrit/hawtio/hawtio-online
DRY_RUN=false

display_usage() {
    cat <<EOT
This script syncs files from the upstream project into the dist-git repository.
Files that require manual intervention are flagged, and others are copied in
place.

Usage: sync.sh [options] -c <current-tag>

with options:
-d, --dry-run     Run in dry-run (non-destructive) mode
-h, --help        This help message
-p, --prev        Previous version of syndesis. Default is extracted from
                  Dockerfile.
EOT
}

main() {

    while [ $# -gt 0 ]
    do
        arg="$1"

        case $arg in
          -h|--help)
            display_usage
            exit 0
            ;;
          -c|--current)
            shift
            CURRENT_VERSION="$1"
            ;;
          -d|--dry-run)
            DRY_RUN=true
            ;;
          -p|--prev)
            shift
            PREV_VERSION="$1"
            ;;
          *)
            echo "Unknown argument: $1"
            display_usage
            exit 1
            ;;
        esac
        shift
    done

    if [ -z "$CURRENT_VERSION" ]
    then
        echo "ERROR: Current version must be specified."
        exit 1
    fi

    if [ ! -d `basename $SCM_URL` ]
    then
        if ! git clone -q $SCM_URL
        then
            echo "ERROR: Could not clone $SCM_URL"
            exit 1
        fi
    fi

    pushd `basename $SCM_URL` > /dev/null

    if ! git checkout -q $CURRENT_VERSION
    then
        echo "ERROR: Could not check out $CURRENT_VERSION"
        popd
        exit 1
    fi

    diff_files=`git diff --name-only $PREV_VERSION docker Dockerfile`

    if [ -z "$diff_files" ]
    then
        echo "No files changed since previous version."
        popd > /dev/null
        exit 0
    fi

    for file in $diff_files
    do
        filename=`basename $file`

        case $file in
          Dockerfile)
            echo "There are changes in $file. Manual merge required."
            ;;
          docker/nginx.conf)
            echo "There are changes in $file. Manual merge required to root/opt/app-root/etc/nginx.d/nginx-fuse-console.conf."
            ;;
          site/*)
            echo "Skipping files in the site/ directory."
            ;;
          *)
            echo "Copying file $file."
            if [ "$DRY_RUN" == "false" ]
            then
                cp -r $file ../${file#docker/*}
            fi
            ;;
        esac
    done
}

main $*
