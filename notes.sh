#!/bin/bash

### Commands ###
function new_board() {
    if [[ -z $1 ]]; then
        error_handler "usage: 'notes new <board name>'"
    fi
    
    ensure_board_does_not_exist "$1"
    echo -e "<board>$1\n</board>" >> ~/.notes

    echo -e "board \033[1m$1\033[0m has been successfully made"
}

function delete_board() {
    if [[ -z $1 ]]; then
        error_handler "usage: 'notes delete <board name>'"
    fi
    
    ensure_board_exists "$1"
    sed -i "/<board>$1$/,/<\/board>/d" ~/.notes

    echo -e "board \033[1m$1\033[0m has been successfully deleted"
}

function stick() {
    if [[ -z $4 || $3 != "on" ]]; then
        error_handler "usage: 'notes stick <note name> <note description> on <board name>'"
    fi

    ensure_note_does_not_exist "$4" "$1"

    sed -i "/<board>$4$/,/<\/board>/s|</board>|<name>$1<\/name> <desc>$2<\/desc>\n</board>|" ~/.notes

    echo -e "note \033[1m$1\033[0m has been successfully added to \033[1m$4\033[0m"
}

function remove() {
    if [[ -z $3 || $2 != "from" ]]; then
        error_handler "usage: 'notes remove <note name> from <board name>'"
    fi

    ensure_note_exists "$3" "$1"

    sed -i "/<board>$3$/,/<\/board>/ { /<name>$1<\/name>/d }" ~/.notes

    echo -e "note \033[1m$1\033[0m has been successfully removed from \033[1m$3\033[0m"
}

function display_boards() {
    echo "Current boards:"
    echo
    sed -n "s|.*<board>\(.*\)|• \x1b[1m\1\x1b[0m|p" ~/.notes
    echo
}

function show() {
    if [[ -z $1 ]]; then
        echo "All notes:"
        echo
        sed -n "s|.*<name>\(.*\)</name>.*<desc>\(.*\)</desc>.*|• \x1b[1m\1\x1b[0m: \2|p" ~/.notes
    else
        ensure_board_exists "$1"
        echo -e "Notes on \033[1m$1\033[0m:"
        echo
        # Clean this up
        sed -n "/<board>$1$/,/<\/board>/p" ~/.notes | sed -n "s|.*<name>\(.*\)</name>.*<desc>\(.*\)</desc>.*|• \x1b[1m\1\x1b[0m: \2|p"
    fi
    echo
}

function help() {
    echo "+---------------------------------+"
    echo "|          Sticky Notes!          |"
    echo "|                                 |"
    echo "|  * Create a new board           |"
    echo "|    to get started.              |"
    echo "|                                 |"
    echo "|  * Then add all the sticky      |"
    echo "|    notes that you want.         |"
    echo "|                                 |"
    echo "|  * Each sticky note consists    |" 
    echo "|    of a name and a description. |"
    echo "|                                 |"
    echo "+---------------------------------+"
    echo
    echo "Usage: notes [OPTION]...{args}"
    echo
    echo "  new       creates a new board"
    echo "            'notes new <board name>'"
    echo
    echo "  delete    deletes a board"
    echo "            'notes delete <board name>'"
    echo
    echo "  stick     sticks a new note on a board"
    echo "            'notes stick <note name> <note description> on <board name>'"
    echo
    echo "  remove    removes a note from a board"
    echo "            'notes remove <note name> from <board name>'"
    echo
    echo "  boards    displays all boards"
    echo "            'notes boards'"
    echo
    echo "  show      shows notes"
    echo "            'notes show'               {shows notes from all boards}"
    echo "            'notes show <board name>'  {shows notes from a given board}"
    echo
}

### Helpers ###
function ensure_note_file_exists() {
    if [[ ! -f "~/.notes" ]]; then
        touch ~/.notes
    fi
}

function ensure_board_exists() {
    output=$(grep -x "<board>$1" ~/.notes)
    if [[ -z $output ]]; then
        error_handler "notes: a board named '$1' does not exist"
    fi
}

function ensure_board_does_not_exist() {
    output=$(grep -x "<board>$1" ~/.notes)
    if [[ -n $output ]]; then
        error_handler "notes: a board named '$1' already exists"
    fi
}

function ensure_note_exists() {
    ensure_board_exists "$1"
    output=$(sed -n "/<board>$1$/,/<\/board>/p" ~/.notes | grep "<name>$2</name>")
    if [[ -z $output ]]; then
        error_handler "notes: a note named '$2' does not exist"
    fi
}

function ensure_note_does_not_exist() {
    ensure_board_exists "$1"
    output=$(sed -n "/<board>$1$/,/<\/board>/p" ~/.notes | grep "<name>$2</name>")
    if [[ -n $output ]]; then
        error_handler "notes: a note named '$2' already exists in $1"
    fi
}

function error_handler() {
    echo -e "$1"
    exit 1
}

### Entry point of program ###
if [[ -n $1 ]]; then
    ensure_note_file_exists
    case "$1" in
        new)
            new_board "$2"
            ;;
        delete)
            delete_board "$2"
            ;;
        stick)
            stick "$2" "$3" "$4" "$5"
            ;;
        remove)
            remove "$2" "$3" "$4"
            ;;
        boards)
            display_boards
            ;;
        show)
            show "$2"
            ;;
        help)
            help
            ;;
        *)
            error_handler "notes: unrecognized option '$1'\nTry 'notes help' for more information."
            ;;
    esac
else
    help
fi
