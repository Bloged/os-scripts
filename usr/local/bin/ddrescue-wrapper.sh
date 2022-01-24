#!/bin/bash
if [[ $# -gt 1 ]]; then
	argv=( "$@" )
	if [ $# -gt 2 ] && [ -b ${argv[-3]} ]; then
			device=${argv[-3]}
			log_file=${argv[-1]}
	elif [ -b ${argv[-2]} ]; then
			device=${argv[-2]}
	else
			echo "Error finding a device in command line"
			exit
	fi
fi

cmd="/usr/bin/ddrescue"
loop_sec="5"
while [[ $# -gt 0 ]]; do
	key="$1"

	case $key in
		--cmd)
		  cmd="$2"
	    shift # past argument
		;;
		-l|--loop)
		  loop_sec="$2"
	    shift # past argument
		;;
		-h|--help)
		  help="1"
		;;
		*)
			cmd_option+=" $1"
		;;
	esac
	shift # past argument or value
done

# Show help?
if [ "${help}" == "1" ]; then
	${cmd} --help | head -n 14
  echo "Wrapper Options:"
	echo -e "      --cmd                      overwrite command [default /usr/bin/ddrescue]"
	echo -e "  -l, --loop                     seconds pause between each retry loop [default 5]"
	${cmd} --help | tail -n +14
	exit
fi

dd_result="2"
sleeping="0"
while [ ! "${dd_result}" -eq 0 ]; do

	if [ ! -b ${device} ]; then
		if [ $( command -v clewarecontrol) ]; then
			clewarecontrol -as 0 1 > /dev/null 2> /dev/null; clewarecontrol -as 1 0 > /dev/null 2> /dev/null; clewarecontrol -as 2 0 > /dev/null 2> /dev/null
		fi
		now=$(date +'%D - %T')
		echo -e '\e[1A\e[K'
		printf '%s No %s found for %02d:%02d:%02d.' "$now" "$device" $((sleeping/3600)) $((sleeping%3600/60)) $((sleeping%60))
		sleeping=$((sleeping + ${loop_sec}))
		sleep $loop_sec
	else
		if [ $( command -v clewarecontrol) ]; then
			clewarecontrol -as 0 0 > /dev/null 2> /dev/null; clewarecontrol -as 1 0 > /dev/null 2> /dev/null; clewarecontrol -as 2 1 > /dev/null 2> /dev/null
		fi
		sleeping="0"
		printf "\nDrive rescuing: %s.\n" "${device}"
		${cmd}${cmd_option}
		dd_result=$?
		if [ ! "${dd_result}" -eq 0 ]; then
			echo "Something went wrong"
		fi

		if [ -n ${log_file} ]; then
			cp ${log_file} ${log_file}.autobck
		fi
	fi
done
