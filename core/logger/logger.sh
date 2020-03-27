import::include constants
import::include ../resources/colors

# Log level variables
declare -g logLevelNone=0
declare -g logLevelDebug=1
declare -g logLevelInfo=2
declare -g logLevelWarning=3
declare -g logLevelError=4
declare -g logLevelCritical=5

# log level presets
declare -ag m_logLevelColors=("${STD_COLOR}" "${GREEN}" "${STD_COLOR}" "${YELLOW}" "${RED}")
declare -ag m_logLevelPrefix=("" "[debug]" "[info]" "[warn]" "[error]")

# Set tab length to 4 spaces
tabs 4

declare m_logLevel="${logLevelInfo}" # Global log level
declare m_logDirectory="/var/log/$(date +%Y%m%d)-$(basename ${BASH_SOURCE[1]} | tr -d - | cut -d. -f1)"
declare m_logFile

# Module flags
declare -g f_debug          # Debug flag
declare -g f_color          # Log color flag
declare -g f_fileOutput     # File output flag
declare -g f_stdOutput=true # Standard output flag
declare -g f_newLine        # New line flag

function logger::enableColor() {
    [ "${1,,}" = "true" ] && f_color="true" || unset f_color
}

function logger::enableDebug() {
    [ "${1,,}" = "true" ] && f_debug="true" || unset f_debug
}

function logger::enableFileOutput() {
    [ "${1,,}" = "true" ] && f_fileOutput="true" || unset f_fileOutput
}

function logger::enableStdOutput() {
    [ "${1,,}" = "true" ] && f_stdOutput="true" || unset f_stdOutput
}

function logger::_printToLogFile() {
    local message="${1}"
    printf "%b${message}" >"${m_logFile}"
}

logger::_log() {
    local level="${1}"
    local message="${2,}"
    local newline="${3,,}"

    local fmt_prefix="${m_logLevelPrefix[${level}]}"
    local fmt_date=$(date +"[%FT%T]")
    local fmt_spacer=" "

    [ "${f_fileOutput}" ] && logger::_printToLogFile "${fmt_date}{fmt_prefix}${fmt_spacer}${message}"
    [ ! "${f_stdOutput}" ] && return 0

    local fmt_ncolor="${STD_COLOR}"
    local fmt_color
    local fmt_trace

    if [ "${f_debug}" ]; then
        fmt_trace="($(basename ${BASH_SOURCE[2]})::${FUNCNAME[2]}:${BASH_LINENO[1]})"
    else
        [ "${level}" = "${logLevelNone}" ] && fmt_spacer=""
        fmt_date=""
        fmt_trace=""
    fi

    if [ "${f_color}" ]; then
        fmt_color="${m_logLevelColors[${level}]}"
    else
        fmt_color=""
        fmt_ncolor=""
    fi

    [ "${f_newLine}" ] && fmt_date="" && fmt_prefix="" && fmt_trace=""

    if [ "${newline}" = "-" ]; then
        fmt_newline=""
        f_newLine=true
    else
        fmt_newline="\n"
        f_newLine=""
    fi

    printf "%b${fmt_date}${fmt_color}${fmt_prefix}${fmt_trace}${fmt_spacer}${message}${fmt_ncolor}${fmt_newline}"
    #([ "${level}" -lt "${m_logLevel}" ]) && ([ ! "${f_debug}" ]) && return 0
}

logger::log() {
    logger::_log "$@"
}

function logger::logDebug() {
    logger::_log "${logLevelDebug}" "$@"
}

function logger::logInfo() {
    logger::_log "${logLevelInfo}" "$@"
}

function logger::logWarning() {
    logger::_log "${logLevelWarning}" "$@"
}

function logger::logError() {
    logger::_log "${logLevelError}" "$@" >&2
}

function logger::setLogLevel() {
    if [ "$#" == 0 ]; then
        logger::logError "first argument must be a logger::logLevel type script name to include"
        exit 1
    fi

    case "${1}" in
    0 | 1 | 2 | 3 | 4)
        m_logLevel="${1}"
        ;;
    *)
        logger::logError "wrong log level"
        exit 1
        ;;
    esac
}

# function logger::setLogDirectory() {
#     return
# }

# function logger::setLogFile() {
#     if [ "$#" == 0 ]; then
#         logger::logError "first argument must be a the path or name of the output log file"
#         exit 1
#     fi

#     local file_name="$(basename ${1}))"
#     local file_dir="$(dirname $(readlink -f -- ${1}))"

#     file_dir="$(readlink -f -- ${m_logDirectory})"

#     mkdir -p "${m_logDirectory}"

#     local relativePathToLogFolder=${2}
#     local logFilePrefix=${3}

#     local logsFolder="$(pwd)/${relativePathToLogFolder}"
#     local dateTimeFormatted=$(date +%Y-%m-%d--%H-%M-%S)

#     logFile="${logsFolder}/${logFilePrefix}-log-${dateTimeFormatted}.txt"
#     echo >"${logFile}"
# }

function logger::banner() {
    local message="${1}"
    local msgoffset=$(printf "%0.s-" $(seq 1 ${#message}))

    logger::_log "${logLevelNone}" "-------${msgoffset}-------"
    logger::_log "${logLevelNone}" "|      ${message}      |"
    logger::_log "${logLevelNone}" "-------${msgoffset}-------"
}
