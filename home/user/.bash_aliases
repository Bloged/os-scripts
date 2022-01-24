# Hack / Convenience
alias _='sudo'
#alias empty-trash='gvfs-trash --empty'
alias ll='ls -alFh'
alias show-kernels='dpkg -l | tail -n +6 | grep -E "linux-image-[0-9]{1}\.[0-9]{1,2}\.[0-9]{1,2}-[0-9]{1,2}-[0-9a-zA-Z]+m"'
alias show-kernels-unused='show-kernels | grep -v $(uname -r)'
alias network='sudo service network-manager restart'
alias watch='watch --color '
alias mp3dir='total_seconds=$(( $(mp3info -p "%S + " *.mp3) 0 )); printf "Duration: %02d:%02d:%02d\n" $((total_seconds / 3600)) $((((total_seconds % 3600)+(total_seconds % 60))/60)) $((total_seconds % 60)); unset total_seconds'
alias ddrescue='ddrescue-wrapper'

# Modern Unix (https://github.com/ibraheemdev/modern-unix)
alias cat='bat' # https://github.com/sharkdp/bat

# apt-get / apt-cache
alias acs='apt-cache search'
alias agi='sudo apt install'
alias agr='sudo apt remove'
alias agu='sudo apt update'
alias agup='sudo apt dist-upgrade -y && sudo apt autoclean -y && sudo apt autoremove --purge -y'
alias agus='agu | grep upgradable 1>/dev/null 2>/dev/null && UPGRADABLE=$(apt list --upgradable | grep -v Listing...) && agup && echo $UPGRADABLE || echo "All packages are up to date."'

# Maven
#alias mvn='mvn -T 1C'
#alias mc='mvn compile'
alias mcl='mvn clean'
alias mi='mvn install'
alias mp='mvn package'
alias mcc='mvn clean compile'
alias mci='mvn clean install'
alias mcp='mvn clean package'
alias mct='mvn clean test'

# MPV
alias mpv-playlist='mpv --ytdl-raw-options="yes-playlist="'

#nmcli
wifi() {
  command nmcli radio wifi $@
}

#noisetorch
noisetorch-supress() {
  #echo "Searching for source $@"
  #echo "Command: noisetorch -l | grep -a1 $@ | grep \"Device ID\" | cut -d':' -f2"
  device=$(noisetorch -l | sed '/Sinks/q' | awk '/Monitor/{getline;next} 1' | grep -a1 $@ | grep "Device ID" | cut -d':' -f2 | xargs)
  if [ ! -z "${device}" ]; then
    echo "Found device ID: \"${device}\""
    command noisetorch -i ${device}
  else
    echo "No device with name '$@' found"
  fi
}

# Vagrant
alias vdestroy='vagrant destroy -f'
alias vhalt='vagrant halt'
alias vprovision='vagrant provision'
alias vssh='vagrant ssh'
alias vup='vagrant up'
alias vupdate='vagrant box update'

#Traffic light
alias tlgreen="sudo clewarecontrol -as 0 0 > /dev/null; sudo clewarecontrol -as 1 0 > /dev/null; sudo clewarecontrol -as 2 1 > /dev/null"
alias tloff="sudo clewarecontrol -as 0 0 > /dev/null; sudo clewarecontrol -as 1 0 > /dev/null; sudo clewarecontrol -as 2 0 > /dev/null"
alias tlorange="sudo clewarecontrol -as 0 0 > /dev/null; sudo clewarecontrol -as 1 1 > /dev/null; sudo clewarecontrol -as 2 0 > /dev/null"
alias tlred="sudo clewarecontrol -as 0 1 > /dev/null; sudo clewarecontrol -as 1 0 > /dev/null; sudo clewarecontrol -as 2 0 > /dev/null"
alias tlcycle="tlred; sleep 5; tlorange; sleep 5; tlgreen; sleep 5; tloff"

# youtube-dl
alias youtube-dl-audio='youtube-dl --ignore-errors --output "%(title)s.%(ext)s" --extract-audio --audio-format mp3'

# Docker
docker() {
  if [[ $@ == 'rmi --all' ]]; then
    command docker ps -q -a | xargs docker rm;  docker images -a -q | xargs docker rmi; docker volumes ls -q | xargs docker volume rm;  docker network ls -q | xargs docker network rm
  else
    command docker "$@"
  fi
}

# Git
git() {
  if [[ $@ == *"--recursive"* ]]; then
    PARAM=${@/"--recursive"/""}
    echo "Let's do recursive: ${PARAM}"
    find . -mindepth 1 -maxdepth 1 -type d -exec sh -c "tput setaf 1; echo {} && tput setaf 7; cd {} && if [ -d ".git" ]; then git ${PARAM} ; else echo 'Not a git repo'; fi" \;
  else
    command git "$@"
  fi
}

# Kubernetes
kubectl() {
  if [[ $@ == "get all" ]]; then
    command kubectl get all,nodes,endpoints
  elif [[ $@ == "get pod" ]]; then
    command kubectl get pod -o wide
  elif [[ $@ == *"*"* ]]; then
    PARAM=($@)
    declare -i search_index
    search_index=${#PARAM[@]}-1
    SEARCH=${PARAM[search_index]}
    if [[ $@ == "logs"* ]]; then
      TYPE="pod"
    else
      declare -i type_index
      type_index=search_index-1
      TYPE=${PARAM[${type_index}]}
    fi
    REPLACE=$(kubectl get ${TYPE} -o name | grep ${SEARCH//"*"/""})
    CMD=${@/${SEARCH}/${REPLACE}}

    command kubectl ${CMD/"${TYPE}/"/""}
  else
    command kubectl "$@"
  fi
}

# Minikube
alias minikube-env='eval $(minikube docker-env)'

alias docking-station='xrandr --setprovideroutputsource 1 0;xrandr --setprovideroutputsource 2 0;xrandr --setprovideroutputsource 3 0;xrandr --setprovideroutputsource 4 0; autorandr --change'
