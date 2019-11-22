
PRINT_MESSAGE() {

	  echo -ne "$@" 2>&1 | tee -a ${log_file}
}

TESTRESULTS_EXIT() {

    if [ $1 -ne 0 ]; then
	      PRINT_MESSAGE "`date` Script failed in ${2}\n"
	      PRINT_MESSAGE "Exiting.\n"
	      exit 1;
    fi
}

VERIFY_VARIABLE() {
    variable_name="${1}"
    variable_description="${2}"
    variable_flag="${3}"
    variable_contents="${4}"
    if [ -z "${variable_contents}" ] ; then
	      PRINT_MESSAGE "Error! Could not find ${variable_description}. Please provide the value using the \"--${variable_flag}\" flag.  Exiting.\n"
	      exit 1
    fi
}

ASK_YES_NO_QUESTION() {
    while true; do
        PRINT_MESSAGE "${1}"
        read REPLY
		    POST_READ ${REPLY}
        case "$REPLY" in
            1 | [Yy] | [Yy][Ee] | [Yy][Ee][Ss])
                return 0
                ;;
            2 | [Nn] | [Nn][Oo])
                return 1
                ;;
            "")
                if [ -n "${2}" ] && [ ${2} -eq 0 ]; then
                    return 0
                elif [ -n "${2}" ] && [ ${2} -eq 1 ]; then
                    return 1
                fi
                ;; # fall through
            *)
                PRINT_MESSAGE "Invalid response. Please enter 1 or 2.\n"
                ;;
        esac
    done
}

