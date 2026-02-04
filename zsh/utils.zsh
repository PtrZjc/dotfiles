export IS_MACOS=$([[ "$OSTYPE" == "darwin"* ]] && echo true || echo false)
export IS_LINUX=$([[ "$OSTYPE" == "linux"* ]] && echo true || echo false)
export CLIP="/tmp/clip"

function clip_copy() {
    local content
    content=$(cat)
    echo -n "$content"
    echo -n "$content" >"$CLIP"
    if $IS_MACOS; then
        echo -n "$content" | pbcopy
    elif command -v xclip &>/dev/null; then
        echo -n "$content" | xclip -selection clipboard
    elif command -v wl-copy &>/dev/null; then
        echo -n "$content" | wl-copy
    fi
}

function clip_paste() {
    if $IS_MACOS; then
        pbpaste
    elif command -v xclip &>/dev/null; then
        xclip -selection clipboard -o
    elif command -v wl-paste &>/dev/null; then
        wl-paste
    fi
}

function open_url() {
    if $IS_MACOS; then
        open "$@"
    elif command -v xdg-open &>/dev/null; then
        xdg-open "$@" &>/dev/null &
    else
        echo "URL: $@"
    fi
}
