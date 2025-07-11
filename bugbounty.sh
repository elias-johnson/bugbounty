#!/bin/bash

function new() {
    if [[ -z $1 ]]; then
        error_handler "bugbounty: missing bug name and description\nusage: 'bugbounty --add <bug name> <bug description>'"
    fi

    if [[ -z $2 ]]; then
        error_handler "bugbounty: missing bug description\nusage: 'bugbounty --add <bug name> <bug description>'"
    fi

    ensure_bug_file_exists
    ensure_bug_does_not_exist "$1"
    echo "<name>$1</name> <desc>$2</desc>" >> ~/.bugs
    echo "bug '$1' has been successfully added"
}

function resolve() {
    if [[ -z $1 ]]; then
        error_handler "bugbounty: missing bug name\nusage: 'bugbounty --resolve <bug name>'"
    fi

    ensure_bug_exists "$1"
    sed -i "/<name>$1<\/name>/d" ~/.bugs
    echo "bug '$1' has been successfully resolved"
}

function edit() {
    if [[ -z $1 || -z $2 || -z $3 ]]; then
        error_handler "bugbounty: missing argument(s)\nusage: 'bugbounty --edit <bug name> <switch> <new bug name>'"
    fi

    case "$2" in 
        "--change-name")
            ensure_bug_exists "$1"
            ensure_bug_does_not_exist "$3"
            
            sed -i "/<name>$1<\/name>/s/<name>$1<\/name>/<name>$3<\/name>/g" ~/.bugs
            echo "bug '$1' successfully renamed to '$3'"

            ;;
        "--change-desc")
            ensure_bug_exists "$1"
            
            sed -i "/<name>$1<\/name>/s/<desc>.*<\/desc>/<desc>$3<\/desc>/g" ~/.bugs
            echo "description of bug '$1' has been successfully updated"

            ;;
        *)
            error_handler "unrecognized switch '$2'\nvalid switches: --change-name, --change-desc"
            ;;
    esac
}

function show() {
    if [[ -z $1 ]]; then
        echo "Current bugs:"
        echo
        sed -n "s|.*<name>\(.*\)</name>.*<desc>\(.*\)</desc>.*|• \x1b[1m\1\x1b[0m: \2|p" ~/.bugs
    else
        echo
        sed -n "s|.*<name>$1</name>.*<desc>\(.*\)</desc>.*|• \x1b[1m$1\x1b[0m: \1|p" ~/.bugs
    fi

    echo
}

function help() {
    echo "Usage: bugbounty [OPTION]...{args}"
    echo
    echo "  -n, --new"
    echo "      adds a new bug to the bug file"
    echo "      bugbounty --new <bug name>"
    echo
    echo "  -r, --resolve"
    echo "      resolves an existing bug and removes it from the bug file"
    echo "      bugbounty --resolve <bug name>"
    echo
    echo "  -e, --edit"
    echo "      edits the name or description of an existing bug"
    echo "      bugbounty --edit <bug name> --change-name <new bug name>"
    echo "      bugbounty --edit <bug name> --change-desc <new bug desc>"
    echo
    echo "  -s, --show"
    echo "      displays existing bugs"
    echo "      bugbounty --show             {shows all bugs}"
    echo "      bugbounty --show <bug name>  {shows single bug}"
    echo
}

function ensure_bug_file_exists() {
    if [[ ! -f "~/.bugs" ]]; then
        touch ~/.bugs
    fi
}

function ensure_bug_exists() {
    output=$(awk '{print $1}' ~/.bugs | sed -n "s:.*<name>\(.*\)</name>.*:\1:p" | grep -x "$1")
    if [[ -z $output ]]; then
        error_handler "bugbounty: a bug named '$1' does not exist"
    fi
}

function ensure_bug_does_not_exist() {
    output=$(awk '{print $1}' ~/.bugs | sed -n "s:.*<name>\(.*\)</name>.*:\1:p" | grep -x "$1")
    if [[ -n $output ]]; then
        error_handler "bugbounty: a bug named '$1' already exists"
    fi
}

function error_handler() {
    echo -e "$1"
    exit 1
}

if [[ -n $1 ]]; then
    case "$1" in
        -n|--new)
            new "$2" "$3"
            ;;
        -r|--resolve)
            resolve "$2"
            ;;
        -e|--edit)
            edit "$2" "$3" "$4"
            ;;
        -s|--show)
            show "$2"
            ;;
        -h|--help)
            help
            ;;
        *)
            error_handler "bugbounty: unrecognized option '$1'\nTry 'bugbounty --help' for more information."
            ;;
    esac
else
    help
fi
