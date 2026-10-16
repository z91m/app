
#!/usr/bin/env bash
set -Eeuo pipefail

# NeoFreeBird builder.
# Usage: build.sh [--sideloaded | --rootless | --trollstore | --rootfull | --dylib]

is_tty=0
if [[ -t 1 ]]; then is_tty=1; fi

bold='' green='' reset=''
if [[ "$is_tty" -eq 1 ]] && command -v tput >/dev/null 2>&1; then
    bold="$(tput bold || true)"
    green="$(tput setaf 2 || true)"
    reset="$(tput sgr0 || true)"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODE=""

say() {
    if [[ -n "${bold}${green}${reset}" ]]; then
        printf "%b%s%b\n" "${bold}${green}" "$1" "${reset}"
    else
        printf "%s\n" "$1"
    fi
}

err() {
    printf "Error: %s\n" "$1" >&2
}

die() {
    err "$1"
    exit 1
}

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTION]

Options:
  --sideloaded   Build an IPA for sideloading.
  --rootless     Build a rootless jailbreak package (.deb).
  --trollstore   Build a TrollStore package (.tipa).
  --rootfull     Build a rootful jailbreak package (.deb).
  --dylib        Build the tweak dynamic library (.dylib) only.
  -h, --help     Show this help.
EOF
}

require_cmd() {
    command -v "$1" >/dev/null 2>&1 ||
        die "'$1' is required but not found in PATH"
}

require_cmd bash
require_cmd make

while [[ $# -gt 0 ]]; do
    case "$1" in
        --sideloaded)
            [[ -n "$MODE" ]] && die "Choose only one build option."
            MODE="sideloaded"
            ;;
        --rootless)
            [[ -n "$MODE" ]] && die "Choose only one build option."
            MODE="rootless"
            ;;
        --trollstore)
            [[ -n "$MODE" ]] && die "Choose only one build option."
            MODE="trollstore"
            ;;
        --rootfull)
            [[ -n "$MODE" ]] && die "Choose only one build option."
            MODE="rootfull"
            ;;
        --dylib)
            [[ -n "$MODE" ]] && die "Choose only one build option."
            MODE="dylib"
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            die "Unknown option: $1"
            ;;
    esac
    shift
done

if [[ -z "$MODE" ]]; then
    usage
    exit 2
fi

clean_tree() {
    if [[ -d "$SCRIPT_DIR/.theos" ]]; then
        rm -rf "$SCRIPT_DIR/.theos"
    fi

    if [[ -f "$SCRIPT_DIR/Makefile" ]]; then
        make -C "$SCRIPT_DIR" clean || true
    fi
}

inject_appex() {
    local ipa
    ipa="$(realpath "$1")"

    local appex="$SCRIPT_DIR/deps/OpenTwitterSafariExtension/OpenTwitterSafariExtension.appex"
    [[ -d "$appex" ]] || die "Safari extension not found: $appex"

    local tmp
    tmp="$(mktemp -d)"

    unzip -q "$ipa" -d "$tmp"

    mkdir -p "$tmp/Payload/Twitter.app/PlugIns"
    cp -R "$appex" "$tmp/Payload/Twitter.app/PlugIns/"

    rm -f "$ipa"

    (
        cd "$tmp"
        zip -qry "$ipa" Payload
    )

    rm -rf "$tmp"
}

# Build FFmpeg dependencies when required.
if [[ ! -f "$SCRIPT_DIR/deps/ffmpeg-kit-next/build/lib/libffmpegkit.a" ]]; then
    say "FFmpeg libraries not found; building from source."
    git -C "$SCRIPT_DIR" submodule update --init deps/ffmpeg-kit-next/upstream
    "$SCRIPT_DIR/deps/ffmpeg-kit-next/build-ffmpeg.sh"
fi

cd "$SCRIPT_DIR"

case "$MODE" in
    dylib)
        say "Building NeoFreeBird dynamic library."
        clean_tree

        make

        # Locate the resulting tweak library.
        DYLIB_PATH=""
        for candidate in \
            "$SCRIPT_DIR/.theos/obj/debug/BHTwitter.dylib" \
            "$SCRIPT_DIR/.theos/obj/BHTwitter.dylib" \
            "$SCRIPT_DIR/.theos/obj/debug/"*.dylib \
            "$SCRIPT_DIR/.theos/obj/"*.dylib
        do
            if [[ -f "$candidate" ]]; then
                DYLIB_PATH="$candidate"
                break
            fi
        done

        [[ -n "$DYLIB_PATH" ]] ||
            die "No dylib was found. Check the Makefile and build output."

        mkdir -p "$SCRIPT_DIR/packages"
        cp "$DYLIB_PATH" "$SCRIPT_DIR/packages/"

        say "Build completed: packages/$(basename "$DYLIB_PATH")"
        ;;

    sideloaded)
        say "Building sideloaded IPA."
        clean_tree

        make SIDELOADED=1

        if [[ -e packages/com.atebits.Tweetie2.ipa ]]; then
            if command -v cyan >/dev/null 2>&1; then
                cyan -i packages/com.atebits.Tweetie2.ipa \
                    -o packages/NeoFreeBird-sideloaded \
                    --ignore-encrypted \
                    -uwf \
                    .theos/obj/debug/zxPluginsInject.dylib \
                    .theos/obj/debug/libbhFLEX.dylib \
                    .theos/obj/debug/BHTwitter.dylib \
                    "layout/Library/Application Support/BHT/BHTwitter.bundle"

                say "Injecting Safari extension."
                inject_appex packages/NeoFreeBird-sideloaded.ipa
            else
                say "cyan is not installed; skipping IPA injection."
            fi
        else
            die "packages/com.atebits.Tweetie2.ipa not found."
        fi

        say "Sideloaded build completed."
        ;;

    rootless)
        say "Building rootless package."
        clean_tree
        export THEOS_PACKAGE_SCHEME="rootless"
        make package
        say "Rootless build completed."
        ;;

    trollstore)
        say "Building TrollStore package."
        clean_tree

        make

        if [[ -e packages/com.atebits.Tweetie2.ipa ]]; then
            if command -v cyan >/dev/null 2>&1; then
                cyan -i packages/com.atebits.Tweetie2.ipa \
                    -o packages/NeoFreeBird-trollstore.tipa \
                    --ignore-encrypted \
                    -uwf \
                    .theos/obj/debug/BHTwitter.dylib \
                    .theos/obj/debug/libbhFLEX.dylib \
                    "layout/Library/Application Support/BHT/BHTwitter.bundle"

                say "Injecting Safari extension."
                inject_appex packages/NeoFreeBird-trollstore.tipa
            else
                say "cyan is not installed; skipping IPA injection."
            fi
        else
            die "packages/com.atebits.Tweetie2.ipa not found."
        fi

        say "TrollStore build completed."
        ;;

    rootfull)
        say "Building rootful package."
        clean_tree
        unset THEOS_PACKAGE_SCHEME || true
        make package
        say "Rootful build completed."
        ;;

    *)
        die "Unknown build mode: $MODE"
        ;;
esac
