#!/bin/bash
# symbolic link tool

# print help information
function show_help() {
    printf "$(
        cat <<EOF
Usage: ${scriptname,,} [OPTION]... [SOURCE_PATH] [TARGET_PATH]
Create a symbolic link of a file/directory or do it for all the files in a directory.

Note: not working with subdirectories, only first layer.

Options:
    -x                  Only executable files
    -a, --all           For all the files of in a directory (no recursive)
    -q, --quiet         Dont print any information about the execution
    --dry-run           Do not make any change, just print what would happen.
    -v, --version       Output version information and exit
    -h, --help          Display this help and exit \n
EOF
    )"

    exit 0
}

declare m_source_path
declare m_target_path
declare -i err=0

# option variables
declare opt_all
declare opt_xfiles
declare opt_dry_run

declare scriptname="Symlink"
declare opts=$(getopt -o xaqvh --long all,quiet,dry-run,version,help -n "$scriptname" -- "$@")

if [ $? != 0 ]; then
    printf "[error] $scriptname: failed parsing options\n"
    exit 1
fi

# arguments parsing function
function get_arguments() {
    while :; do
        case "$1" in
        -x)
            opt_xfiles=true
            shift
            ;;
        -a | --all)
            opt_all=true
            shift
            ;;
        -q | --quiet)
            exec 1>/dev/null
            shift
            ;;

        -v | --version)
            echo "$scriptname 0.1.0"
            exit 0
            ;;
        --dry-run)
            printf "[info] dry-run execution\n"
            opt_dry_run=true
            shift
            ;;
        -h | -\? | --help)
            show_help # display help information
            ;;
        --) # end of options
            shift
            ;;
        -?*)
            printf "[warn] wrong option. Try --help option for more information.\n"
            shift
            exit 1
            ;;
        *) # default case: No more options, so break out of the loop
            [ "$m_source_path" -a "$m_target_path" ] && break
            [ ! "$1" ] && show_help
            m_source_path=$(readlink -f -- $1)
            m_target_path=$(readlink -f -- $2)
            shift $(($OPTIND + 1)) # shift the two mandatory arguments
            ;;
        esac
    done
}

# arguments cheching function
function check_arguments() {
    if [ ! "$m_source_path" ]; then
        printf "[error] no arguments provided\n"
        exit 1
    fi

    if [ "$opt_xfiles" -o "$opt_all" ]; then
        [ ! -d "$m_source_path" ] && printf "[error] source path must be a directory\n" && err+=1
        [ ! -d "$m_target_path" ] && printf "[error] target path must be a directory\n" && err+=1
        [ "$err" != 0 ] && exit "$err"
    fi

    if [ -d "$m_source_path" ]; then
        return 0
    elif [ -f "$m_source_path" ]; then
        return 0
    else
        printf "[error] ${m_source_path} no such a file or directory\n"
        exit 1
    fi
}

# main function which executes the script logic
function main() {
    # argument parsing and checking execution
    get_arguments "$@"
    check_arguments

    local file_list_cmd

    [ "$opt_xfiles" ] && file_list_cmd=$(ls -FA $m_source_path | awk '/*/ {print $1}' | cut -d* -f 1)
    [ "$opt_all" ] && file_list_cmd=$(ls -pA $m_source_path | awk '!/\// {print $1}')

    ## -- script logic -- ##
    if [ "$opt_xfiles" -o "$opt_all" ]; then
        declare tfilee
        declare -i err=0
        for sfile in $file_list_cmd; do
            if [[ "$sfile" =~ ".sh" ]]; then
                tfile=$(echo ${sfile} | cut -d. -f1)
            else
                tfile="$sfile"
            fi

            printf "[info] creating symbolic link ($tfile) of file $sfile... "
            if [ "$opt_dry_run" ]; then
                printf "OK\n"
                continue
            fi

            ln -sf "$m_source_path/$sfile" "$m_target_path/$tfile" >/dev/null 2>&1
            if [ $? != 0 ]; then
                printf "failed\n"
                err+=1
            else
                printf "done\n"
            fi
        done

        [ "$err" != 0 ] && printf "[info] symlinking failed!\n" || printf "[info] symlinking successful!\n"
        exit
    fi

    printf "[info] creating symbolic link ($m_target_path) of file $m_source_path...\n"
    [ ! "$opt_dry_run" ] && ln -sf "$m_source_path" "$m_target_path" >/dev/null 2>&1
    [ $? != 0 ] && printf "[info] symlinking failed!\n" || printf "[info] symlinking successful!\n"
}

## -- script execution --##
main "$@" # "$@" transfer script global scope (with all the arguments from user-land)
