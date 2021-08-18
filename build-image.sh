#!/bin/bash

set -o pipefail
set -eu

BASE_BUILD_URL=${BASE_BUILD_URL:-http://indy.psi.redhat.com/api/content/maven/group/redhat-builds}

display_usage() {
    cat <<EOT
Build script to start the docker build of fuse-console-openshift.
Specify the redhat version of hawtio-online produced.

Usage: build-image.sh [options] -v <hawtio-online-version>

with options:

-d, --dry-run     Do not commit any changes, and do not run the build.
    --scratch     When running the build, do a scratch build (only applicable if NOT running in dry-run mode)
-h, --help        This help message

EOT
}

download() {
    local url=$1
    local filename=`basename $url`

    if [ -f $filename ]
    then
        echo "File $filename already exists. Skipping download."
        return 0
    fi

    echo "Downloading $url"
    wget -q $url
    if [ $? -ne 0 ]
    then
        echo "Error downloading file from $url."
        return 1
    fi

    # See if there is a md5 file
    if [ -f $filename.md5 ]
    then
        rm $filename.md5
    fi

    wget -q $url.md5
    if [ $? -ne 0 ]
    then
        echo "Error downloading file from $url.md5."
        return 1
    fi

    if ! md5sum $filename | cut -d ' ' -f 1 | tr -d '\n' | cmp - $filename.md5
    then
        echo "ERROR: md5sums do not match for $filename"
        return 1
    fi

    return 0

}

update_dockerfile() {
    local hawtioOnlineVersion=$1
    local dryRun=$2

    echo "Updating Dockerfile"
    sed -i "/^ENV HAWTIO_ONLINE_VERSION /{s/ [^ ]*/ $hawtioOnlineVersion/2}" Dockerfile

    if [ "$dryRun" == "false" ]
    then
        git add Dockerfile
    fi
}

osbs_build() {
    local version=$1
    local scratchBuild=$2

    num_files=$(git status --porcelain  | { egrep '^\s?[MADRC]' || true; } | wc -l)
    if ((num_files > 0)) ; then
        echo "Committing $num_files"
        git commit -m"Updated for build of hawtio-online $version"
        git push
    else
        echo "There are no files to be committed. Skipping commit + push"
    fi

    if [ "$scratchBuild" == "false" ]
    then
        echo "Starting OSBS build"
        rhpkg container-build --repo-url http://git.engineering.redhat.com/git/users/ttomecek/osbs-signed-packages.git/plain/released.repo
    else
        local branch=$(git rev-parse --abbrev-ref HEAD)
        local build_options=""

        # If we are building on a private branch, then we need to use the correct target
        if [[ $branch == *"private"* ]] ; then
            # Remove the private part of the branch name: from private-opiske-fuse-7.4-openshift-rhel-7
            # to fuse-7.4-openshift-rhel-7 and we add the containers candidate to the options
            local target="${branch#*-*-}-containers-candidate"

            build_options="${build_options} --target ${target}"
            echo "Using target ${target} for the private container build"
        fi

        echo "Starting OSBS scratch build"
        rhpkg container-build --scratch ${build_options} --repo-url http://git.engineering.redhat.com/git/users/ttomecek/osbs-signed-packages.git/plain/released.repo
    fi
}

main() {
    HAWTIO_ONLINE_VERSION=
    DRY_RUN=false
    SCRATCH=false

    # Parse command line arguments
    while [ $# -gt 0 ]
    do
        arg="$1"

        case $arg in
          -h|--help)
            display_usage
            exit 0
            ;;
          -d|--dry-run)
            DRY_RUN=true
            ;;
          --scratch)
            SCRATCH=true
            ;;
          -v|--version)
            shift
            HAWTIO_ONLINE_VERSION="$1"
            ;;
          *)
            echo "Unknonwn argument: $1"
            display_usage
            exit 1
            ;;
        esac
        shift
    done

    # Check that syndesis version is specified
    if [ -z "$HAWTIO_ONLINE_VERSION" ]
    then
        echo "ERROR: Hawtio-online version wasn't specified."
        exit 1
    fi

    # Download Hawtio-online artifact
    if ! download ${BASE_BUILD_URL}/io/hawt/hawtio-online/$HAWTIO_ONLINE_VERSION/hawtio-online-$HAWTIO_ONLINE_VERSION-dist.tar.gz
    then
        exit 1
    fi

    if ! rhpkg new-sources hawtio-online-$HAWTIO_ONLINE_VERSION-dist.tar.gz
    then
        echo "Error uploading hawtio-online-$HAWTIO_ONLINE_VERSION-dist.tar.gz to lookaside cache"
        exit 1
    fi

    update_dockerfile $HAWTIO_ONLINE_VERSION $DRY_RUN

    if [ "$DRY_RUN" == "false" ]
    then
        osbs_build $HAWTIO_ONLINE_VERSION $SCRATCH
    fi
}

main $*
