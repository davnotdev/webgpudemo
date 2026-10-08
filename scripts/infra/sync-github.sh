#!/usr/bin/env bash

set -e

# Downloads new demo projects into local `builds/` 

cd "$(dirname "$(realpath "$0")")/../.."

if [ -z "$SYNC_GITHUB_PULLED" ]; then
    git pull --ff-only
    SYNC_GITHUB_PULLED=1 exec bash scripts/infra/sync-github.sh "$@"
fi

mkdir -p builds/

tags=$(gh release list --limit 1000 --json tagName --jq '.[].tagName')

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

        demo=${asset%.zip}
        demo=${demo%-release}
        unzip -q "builds/$tag.partial/$asset" -d "builds/$tag.partial/$demo"
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
