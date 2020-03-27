####### NEEDED -- export BASH_ENV=/home/dev/linux-tools/core/import.sh

# @description Sources relative script file.
#
# @example
#   import::include logger.sh
#
# @arg $1 string Script name to source.
# @stdout ? Whatever sourced script outputs.
# @exitcode ? Whatever sourced script returns.
import::include() {
    if [ "$#" == 0 ]; then
        printf "[error] first argument should be script name to include"
        return 1
    fi

    local source_path="${1}"
    local name=$(basename ${1^^} | tr -d - | cut -d. -f1)
    local current_dir=$(dirname "${BASH_SOURCE[1]}")

    declare -n name_ref="${name}_SOURCED"

    # Include guard
    if [ "${name_ref+x}" ]; then
        return 0
    else
        readonly name_ref=1
        source $(readlink -f -- "${current_dir}/${source_path}")
        export BASH_ENV="${BASH_ENV} $(readlink -f -- "${current_dir}/${source_path}")"
    fi
}
