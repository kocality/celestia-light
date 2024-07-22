#!/bin/bash

# Define colors
RED="\033[31m"
YELLOW="\033[33m"
GREEN="\033[32m"
NORMAL="\033[0m"

# Message
echo -e "${GREEN}This script was made with love by @kkocality <3${NORMAL}"
sleep 8

install_dependencies() {
    echo -e "${YELLOW}Installing System Updates and Dependencies${NORMAL}"
    sudo apt update -y && sudo apt upgrade -y
    sudo apt-get install -y curl tar wget aria2 clang pkg-config libssl-dev jq build-essential git make ncdu screen
}

install_docker() {
    echo -e "${YELLOW}Installing Docker${NORMAL}"
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    sudo docker run hello-world
}

setup_celestia_node() {
    echo -e "${YELLOW}Setting up Celestia Light Node${NORMAL}"
    export NETWORK=celestia
    export NODE_TYPE=light
    export RPC_URL=http://public-celestia-consensus.numia.xyz

    cd $HOME
    mkdir -p my-node-store
    sudo chown 10001:10001 $HOME/my-node-store

    echo -e "${YELLOW}Initializing Celestia Light Node${NORMAL}"
    docker run -e NODE_TYPE=$NODE_TYPE -e P2P_NETWORK=$NETWORK \
        -v $HOME/my-node-store:/home/celestia \
        ghcr.io/celestiaorg/celestia-node:v0.13.7 \
        celestia light init --p2p.network $NETWORK

    echo -e "${GREEN}Please save your wallet information and mnemonics securely.${NORMAL}"
    
    while true; do
        read -p "Did you save your wallet information and mnemonics? (yes/no): " yn
        case $yn in
            [Yy]* ) break;;
            [Nn]* ) echo -e "${RED}Please save your wallet information and mnemonics before continuing.${NORMAL}";;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

start_celestia_node() {
    echo -e "${YELLOW}Starting Celestia Light Node${NORMAL}"
    screen -S celestia-node -dm bash -c "docker run -e NODE_TYPE=$NODE_TYPE -e P2P_NETWORK=$NETWORK \
        -v $HOME/my-node-store:/home/celestia \
        ghcr.io/celestiaorg/celestia-node:v0.13.7 \
        celestia light start --core.ip $RPC_URL"
}

main() {
    install_dependencies
    install_docker
    setup_celestia_node
    start_celestia_node
    echo -e "${GREEN}Celestia Light Node setup and started successfully.${NORMAL}"
    echo -e "${YELLOW}To view the logs, use: screen -r celestia-node${NORMAL}"

    
    echo -e "${GREEN}LM${NORMAL}"
}

# Execute the main function
main
