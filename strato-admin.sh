#!/bin/bash

set -e

registry="registry-aws.blockapps.net:5000"
usage='

   --start                             Start STRATO single node 
   --start-multi                       Start STRATO multinode network with 3 STRATO nodes 
   --stop                              Stop STRATO containers 
'

 function setEnv {
   echo "$1 = ${!1}"
   echo "Setting Env"
    export lazyBlocks=false
    export miningAlgorithm=SHA
    export apiUrlOverride=http://strato:3000
    export blockTime=2
    export minBlockDifficulty=8192
    export genesisBlock=$(< gb.json)
    export stratoHost=nginx
    export ssl=false
 }

function runStrato {
if grep -q "${registry}" ~/.docker/config.json
then
    setEnv
    if [[ $multi -eq 1 ]] 
    then
      exec docker-compose up -f docker-compose.multinode.yml -d
    else
      exec docker-compose up -d
    fi
else
    echo "Something went wrong! Please check the docker-compose.yml and access to the registry"
    exit 3
fi
}

function stopStrato {
    echo "Stopping STRATO containers"
    docker-compose kill 
    docker-compose down
}

echo "
    ____  __           __   ___
   / __ )/ /___  _____/ /__/   |  ____  ____  _____
  / __  / / __ \/ ___/ //_/ /| | / __ \/ __ \/ ___/
 / /_/ / / /_/ / /__/ ,< / ___ |/ /_/ / /_/ (__  )
/_____/_/\____/\___/_/|_/_/  |_/ .___/ .___/____/
                              /_/   /_/
"

if ! docker ps &> /dev/null
then
    echo 'Error: docker is required to be installed and configured for non-root users: https://www.docker.com/'
    exit 1
fi

if ! docker-compose -v &> /dev/null
then
    echo 'Error: docker-compose is required: https://docs.docker.com/compose/install/'
    exit 2
fi

case $1 in
  "--start")
     runStrato
     exit 0
     ;;
  "--start-multi")
     multi=1
     runStrato
     exit 0
     ;;
 "--stop")
     echo "Stopping STRATO containers"
     stopStrato 
     exit 0
     ;; 
 "--help")
     echo "$0 usage:"
     echo "$usage"
     exit 0
     ;;
   *)
     echo >&2 "Invalid argument: $1.  Valid arguments are:"
     printf "%s" "$usage"
     exit 1
     ;;
 esac
