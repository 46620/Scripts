#!/bin/bash

# What fucking kind of script is this?
# This is packwiz deploy script, it deploys every packwiz pack from a desired git repo

# TODO:
#       - Tell the user what the fuck is going on (NEEDED)
#       - Error checking (NEEDED)
#       - Only deploy branches that have a pack.toml (Recommended, very easy to set up)
#       - Create a barebone prism instance (This will be handled by a different script)

function vars() {
    readonly USE_ENV=1  # In the future a .env will be required, with an example being in this repo. I dont know how I want to set it up currently so its not required
    if [ $USE_ENV -eq 0 ]
    then
        readonly REPO_URL=  # git repo (include ssh:// or https://)
        readonly PACKWIZ_ROOT=  # Where packs will be deployed
        readonly PACKWIZ_URL_BASE=  # URL of PACKWIZ_ROOT
        readonly SERVER_BASE_URL=  # Base URL of servers (this script is to be used with itzg/docker-minecraft-server and itzg/mc-router, so we gotta kinda expect all this)
        readonly SERVER_ROOT=  # Root folder of where game servers will be stored
    else
        source .env
    fi
}

function deploy() {
    echo " [*  ] Deploying, please wait..."
    git clone -q "$REPO_URL" "/tmp/$(basename $REPO_URL)"
    for branch in $(git -C "/tmp/$(basename $REPO_URL)" branch -r | grep -v '\->'); do  # idr where I got this from
        git -C "/tmp/$(basename $REPO_URL)" branch -q --track ${branch#origin/} $branch 2> /dev/null
        git -C "/tmp/$(basename $REPO_URL)" fetch -a
    done

    PACKS=($(git -C "/tmp/$(basename $REPO_URL)" branch --format='%(refname:short)'))
    for BRANCH in "${PACKS[@]}"
    do
        echo " [*  ] Deploying $BRANCH"
        mkdir -p "$PACKWIZ_ROOT/$BRANCH"
        git -C "/tmp/$(basename $REPO_URL)" archive "$BRANCH" | tar -x -C "$PACKWIZ_ROOT/$BRANCH"
    done
    echo " [*  ] Deployment done!"
}

function create_server() {
    echo "[*  ] Creating docker file for instances"
    for INSTANCE in "${PACKS[@]}"
    do
        if ! [ -f $PACKWIZ_ROOT/$INSTANCE/pack.toml ]
        then
            echo " [ * ] $INSTANCE does not have a pack.toml. Please check that it properly copied."
            continue
        fi
        CRC_NAME=$(echo $INSTANCE | rhash -p %c -)
        SERVER_URL="$CRC_NAME.$SERVER_BASE_URL"
        MINECRAFT_VERSION=$(cat $PACKWIZ_ROOT/$INSTANCE/pack.toml | grep minecraft | cut -d'"' -f2)
        MODLOADER=$(cat $PACKWIZ_ROOT/$INSTANCE/pack.toml | tail -1 | cut -d'=' -f1 | tr a-z A-Z)
        echo " [*  ] Generating $SERVER_URL"
        cat <<EOF > "$PACKWIZ_ROOT/$INSTANCE/$SERVER_URL.yml"  # TODO: Find out if MODLOADER has any issues
services:
  $SERVER_URL:
    container_name: $SERVER_URL
    image: itzg/minecraft-server
    environment:
      EULA: "TRUE"
      VERSION: $MINECRAFT_VERSION
      TYPE: $MODLOADER
      PACKWIZ_URL: $PACKWIZ_URL_BASE/$INSTANCE/pack.toml
      GUI: "FALSE"
      MEMORY: "6G"  # 6G is a semi decent default I can think of for now.
      USER_UID: "1000"
      USER_GID: "1000"
      ENABLE_COMMAND_BLOCK: "true"
      SPAWN_PROTECTION: "0"
    tty: true
    stdin_open: true
    restart: unless-stopped
    volumes:
      - $SERVER_ROOT/$SERVER_URL:/data
EOF
    done
}

function cleanup() {
    rm -rf "/tmp/$(basename $REPO_URL)"
}

function main() {
    vars
    deploy
    create_server
    cleanup
}

main
