#!/usr/bin/env bash

set -e

# Downloads new demo projects into local `builds/` 
# Usage: sync-github.sh [--latest]

cd "$(dirname "$(realpath "$0")")/../.."

LATEST_ONLY=0
for arg in "$@"; do
    case $arg in
        --latest)
            LATEST_ONLY=1
            ;;
        *)
            echo "Error: unknown argument: $arg"
            exit 1
            ;;
    esac
done

if [ -z "$SYNC_GITHUB_PULLED" ]; then
    git pull --ff-only
    SYNC_GITHUB_PULLED=1 exec bash scripts/infra/sync-github.sh "$@"
fi

if [ -z "$GH_TOKEN" ] && [ -f .env ]; then
    token=$(sed -nE 's/^(export[[:space:]]+)?GH_TOKEN=//p' .env | tail -n 1 | tr -d '\r')
    token=${token#[\"\']}
    token=${token%[\"\']}
    if [ -n "$token" ]; then
        export GH_TOKEN=$token
    fi
fi

mkdir -p builds/

tags=$(gh release list --limit 1000 --json tagName --jq '.[].tagName')
if [ "$LATEST_ONLY" = 1 ]; then
    tags=$(head -n 1 <<< "$tags")
fi

for tag in $tags; do
    if [ -d "builds/$tag" ]; then
        echo "skipped: $tag"
        continue
    fi

    rm -rf "builds/$tag.partial"
    mkdir -p "builds/$tag.partial"

    for asset in $(gh release view "$tag" --json assets --jq '.assets[].name'); do
        case $asset in
            godot-linuxbsd-*|godot-windows-*|godot.web.*)
                continue
                ;;
            *.zip)
                ;;
            *)
                continue
                ;;
        esac

        echo "downloading: $tag/$asset"
        gh release download "$tag" --pattern "$asset" --dir "builds/$tag.partial"

        case $asset in
            godot-demo-projects-mobile-release.zip)
                destination="godot-demo-projects/mobile"
                ;;
            godot-demo-projects-forward_plus-release.zip)
                destination="godot-demo-projects/forward_plus"
                ;;
            *)
                demo=${asset%.zip}
                demo=${demo%-release}
                destination=$demo
                ;;
        esac

        mkdir -p "builds/$tag.partial/$destination"
        unzip -q "builds/$tag.partial/$asset" -d "builds/$tag.partial/$destination"
        rm "builds/$tag.partial/$asset"
    done

    mv "builds/$tag.partial" "builds/$tag"
    echo "synced: $tag"
done

latest=$(head -n 1 <<< "$tags")
if [ -n "$latest" ]; then
    ln -sfn "$latest" builds/latest
    echo "latest: $latest"
fi

bash scripts/infra/build-md.sh index.md builds/index.html
