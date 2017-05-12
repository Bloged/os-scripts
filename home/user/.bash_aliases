# Hack / Convenience
alias show-kernels='dpkg -l | tail -n +6 | grep -E "linux-image-[0-9]{1}\.[0-9]\.[0-9]"'
alias show-kernels-unused='show-kernels | grep -v $(uname -r)'
alias network='sudo service network-manager restart'
alias watch='watch '

# apt-get / apt-cache
alias acs='apt-cache search'
alias agi='sudo apt install'
alias agr='sudo apt remove'
alias agu='sudo apt update'
alias agup='sudo apt dist-upgrade -y && sudo apt autoclean -y && sudo apt autoremove --purge -y'
alias agus='agu | grep upgradable 1>/dev/null 2>/dev/null && UPGRADABLE=$(apt list --upgradable | grep -v Listing...) && agup && echo $UPGRADABLE || echo "All packages are up to date."'

# Maven
#alias mvn='mvn -T 1C'
alias mc='mvn compile'
alias mcl='mvn clean'
alias mi='mvn install'
alias mp='mvn package'
alias mcc='mvn clean compile'
alias mci='mvn clean install'
alias mcp='mvn clean package'

# Vagrant
alias vdestroy='vagrant destroy -f'
alias vhalt='vagrant halt'
alias vprovision='vagrant provision'
alias vssh='vagrant ssh'
alias vup='vagrant up'
alias vupdate='vagrant box update'

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
minikube() {
  if [[ $@ == *"start"* ]]; then
    echo "Adding insecure repository:"
    echo "  - repository.falcon:8888"
    echo "  - nexus.stgfalcon.uk5.rpc.payucloud.net:8888"
    command minikube "$@" --insecure-registry=repository.falcon:8888 --insecure-registry=nexus.stgfalcon.uk5.rpc.payucloud.net:8888
  else
    command minikube "$@"
  fi
}

