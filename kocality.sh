#!/bin/bash

# Define colors and styles
RED="\033[31m"
YELLOW="\033[33m"
GREEN="\033[32m"
NORMAL="\033[0m"
BOLD="\033[1m"
ITALIC="\033[3m"

# Language selection
echo -e "${YELLOW}Select Language / Dil Seçiniz:${NORMAL}"
echo -e "1) English"
echo -e "2) Türkçe"
read -p "Enter your choice (1/2): " lang_choice

while [[ "$lang_choice" != "1" && "$lang_choice" != "2" ]]; do
    echo -e "${RED}Invalid choice. Please enter 1 or 2.${NORMAL}"
    read -p "Enter your choice (1/2): " lang_choice
done

if [ "$lang_choice" -eq 1 ]; then
    lang="EN"
else
    lang="TR"
fi

# Version API
VERSION=$(curl -s "https://api.github.com/repos/celestiaorg/celestia-node/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

# Check if VERSION is empty
if [ -z "$VERSION" ]; then
    if [ "$lang" == "EN" ]; then
        echo "Failed to fetch the latest version. Exiting."
    else
        echo "En son sürüm alınamadı. Çıkılıyor."
    fi
    exit 1
fi

# Remove Node
remove_celestia_node() {
    if [ "$lang" == "EN" ]; then
        echo -e "${RED}Removing Celestia Light Node...${NORMAL}"
    else
        echo -e "${RED}Celestia Light Node kaldırılıyor...${NORMAL}"
    fi
    NODE_ID=$(sudo docker ps -a -q --filter ancestor=ghcr.io/celestiaorg/celestia-node:$VERSION)
    if [ -n "$NODE_ID" ]; then
        sudo docker stop $NODE_ID >/dev/null 2>&1
        sudo docker rm $NODE_ID >/dev/null 2>&1
        sudo rm -rf $HOME/my-node-store
        screen -ls | grep -o '[0-9]*\.celestia-node' | awk '{print $1}' | xargs -I {} screen -S {} -X quit
        if [ "$lang" == "EN" ]; then
            echo -e "${GREEN}Celestia Light Node removed successfully.${NORMAL}"
        else
            echo -e "${GREEN}Celestia Light Node başarıyla kaldırıldı.${NORMAL}"
        fi
    else
        if [ "$lang" == "EN" ]; then
            echo -e "${YELLOW}No node found to remove.${NORMAL}"
        else
            echo -e "${YELLOW}Kaldırılacak node bulunamadı.${NORMAL}"
        fi
    fi
}

# Install system dependencies
install_dependencies() {
    if [ "$lang" == "EN" ]; then
        echo -e "${YELLOW}Installing System Updates and Dependencies...${NORMAL} (This may take a few minutes)"
    else
        echo -e "${YELLOW}Sistem Güncellemeleri ve Bağımlılıklar Yükleniyor...${NORMAL} (Bu birkaç dakika sürebilir)"
    fi
    sudo apt update -y >/dev/null 2>&1 && sudo apt upgrade -y >/dev/null 2>&1
    sudo apt-get install -y curl tar wget aria2 clang pkg-config libssl-dev jq build-essential git make ncdu screen >/dev/null 2>&1
    if [ "$lang" == "EN" ]; then
        echo -e "${GREEN}System Updates and Dependencies installed successfully.${NORMAL}"
    else
        echo -e "${GREEN}Sistem Güncellemeleri ve Bağımlılıklar başarıyla yüklendi.${NORMAL}"
    fi
}

# Install Docker
install_docker() {
    if ! command -v docker &> /dev/null; then
        if [ "$lang" == "EN" ]; then
            echo -e "${YELLOW}Installing Docker...${NORMAL}"
        else
            echo -e "${YELLOW}Docker Yükleniyor...${NORMAL}"
        fi
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update >/dev/null 2>&1
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io >/dev/null 2>&1
        sudo docker run hello-world >/dev/null 2>&1
        if [ "$lang" == "EN" ]; then
            echo -e "${GREEN}Docker installed successfully.${NORMAL}"
        else
            echo -e "${GREEN}Docker başarıyla yüklendi.${NORMAL}"
        fi
    else
        if [ "$lang" == "EN" ]; then
            echo -e "${GREEN}Docker is already installed.${NORMAL}"
        else
            echo -e "${GREEN}Docker zaten yüklü.${NORMAL}"
        fi
    fi
}

setup_celestia_node() {
    if [ "$lang" == "EN" ]; then
        echo -e "${YELLOW}Setting up Celestia Light Node...${NORMAL}"
    else
        echo -e "${YELLOW}Celestia Light Node kuruluyor...${NORMAL}"
    fi
    export NETWORK=celestia
    export NODE_TYPE=light
    export RPC_URL=http://public-celestia-consensus.numia.xyz

    cd $HOME
    mkdir -p my-node-store
    sudo chown 10001:10001 $HOME/my-node-store

    if [ "$lang" == "EN" ]; then
        echo -e "${YELLOW}Initializing Celestia Light Node...${NORMAL}"
    else
        echo -e "${YELLOW}Celestia Light Node başlatılıyor...${NORMAL}"
    fi
    OUTPUT=$(sudo docker run -e NODE_TYPE=$NODE_TYPE -e P2P_NETWORK=$NETWORK \
        -v $HOME/my-node-store:/home/celestia \
        ghcr.io/celestiaorg/celestia-node:$VERSION \
        celestia light init --p2p.network $NETWORK)

    if [ "$lang" == "EN" ]; then
        echo -e "${RED}Please save your wallet information and mnemonics securely.${NORMAL}"
        echo -e "${RED}NAME and ADDRESS:${NORMAL}"
        echo -e "${NORMAL}$(echo "$OUTPUT" | grep -E 'NAME|ADDRESS')${NORMAL}"
        echo -e "${RED}MNEMONIC (save this somewhere safe!!!):${NORMAL}"
        echo -e "${NORMAL}$(echo "$OUTPUT" | sed -n '/MNEMONIC (save this somewhere safe!!!):/,$p' | tail -n +2)${NORMAL}"
        echo -e "${RED}This information will not be saved automatically. Make sure to record it manually.${NORMAL}"
    else
        echo -e "${RED}Cüzdan bilgilerinizi ve anımsatıcılarınızı güvenli bir şekilde kaydedin.${NORMAL}"
        echo -e "${RED}İSİM ve ADRES:${NORMAL}"
        echo -e "${NORMAL}$(echo "$OUTPUT" | grep -E 'NAME|ADDRESS')${NORMAL}"
        echo -e "${RED}MNEMONIC (bunu güvenli bir yere kaydedin!!!):${NORMAL}"
        echo -e "${NORMAL}$(echo "$OUTPUT" | sed -n '/MNEMONIC (save this somewhere safe!!!):/,$p' | tail -n +2)${NORMAL}"
        echo -e "${RED}Bu bilgiler otomatik olarak kaydedilmeyecek. Kaydettiğinizden emin olun.${NORMAL}"
    fi

    while true; do
        if [ "$lang" == "EN" ];then
            read -p "Did you save your wallet information and mnemonics? (yes/no): " yn
        else
            read -p "Cüzdan bilgilerinizi ve mnemonic'lerinizi kaydettiniz mi? (evet/hayır): " yn
        fi
        case $yn in
            [Yy]* | [Ee]* ) break;;
            [Nn]* | [Hh]* ) if [ "$lang" == "EN" ]; then echo -e "${RED}Please save your wallet information and mnemonics before continuing.${NORMAL}"; else echo -e "${RED}Lütfen devam etmeden önce cüzdan bilgilerinizi ve anımsatıcılarınızı kaydedin.${NORMAL}"; fi;;
            * ) if [ "$lang" == "EN" ]; then echo "Please answer yes or no."; else echo "Lütfen evet ya da hayır cevabı verin."; fi;;
        esac
    done
}

start_celestia_node() {
    if [ "$lang" == "EN" ]; then
        echo -e "${YELLOW}Starting Celestia Light Node...${NORMAL}"
    else
        echo -e "${YELLOW}Celestia Light Node başlatılıyor...${NORMAL}"
    fi

    screen -S celestia-node -dm bash -c "sudo docker run -e NODE_TYPE=$NODE_TYPE -e P2P_NETWORK=$NETWORK \
        -v $HOME/my-node-store:/home/celestia \
        ghcr.io/celestiaorg/celestia-node:$VERSION \
        celestia light start --core.ip $RPC_URL --p2p.network $NETWORK"
    
    if [ "$lang" == "EN" ]; then
        echo -e "${GREEN}Celestia Light Node started successfully.${NORMAL}"
        echo -e "${YELLOW}To view the logs, use: screen -r celestia-node${NORMAL}"
        echo -e "${YELLOW}To detach from screen, press Ctrl+A, then D.${NORMAL}"
    else
        echo -e "${GREEN}Celestia Light Node başarıyla başlatıldı.${NORMAL}"
        echo -e "${YELLOW}Logları görmek için: screen -r celestia-node${NORMAL}"
        echo -e "${YELLOW}Screen'den çıkmak için, Ctrl+A, sonra D tuşlarına basın.${NORMAL}"
    fi
    echo -e "${GREEN}
  _      __  __ 
 | |    |  \/  |
 | |    | |\/| |
 | |____| |  | |
 |______|_|  |_|
 ${NORMAL}"
}

# Main script execution
clear

echo -e "${GREEN}
 _                   _ _ _         
| | _____   ___ __ _| (_) |_ _   _ 
| |/ / _ \ / __/ _\` | | | __| | | |
|   < (_) | (_| (_| | | | |_| |_| |
|_|\_\___/ \___\__,_|_|_|\__|\__, |
                             |___/ 
${NORMAL}"
if [ "$lang" == "EN" ]; then
    echo -e "${GREEN}${BOLD}${ITALIC}Welcome to the one-command script for Celestia Light Node!${NORMAL}"
    echo -e ""
    echo -e "${GREEN}${BOLD}${ITALIC}This script was made with love by ${BOLD}@kkocality <3${NORMAL}"
else
    echo -e "${GREEN}${BOLD}${ITALIC}Celestia Light Node için tek komutluk script'e hoş geldiniz!${NORMAL}"
    echo -e ""
    echo -e "${GREEN}${BOLD}${ITALIC}Bu script @kkocality tarafından sevgiyle yapıldı <3${NORMAL}"
fi
sleep 7

if [ "$lang" == "EN" ]; then
    echo -e "${YELLOW}What would you like to do?${NORMAL}"
    echo -e ""
    echo -e "1) Setup Celestia Light Node"
    echo -e "2) Remove Celestia Light Node"
    echo -e ""
    read -p "Enter your choice (1/2): " choice
else
    echo -e "${YELLOW}Ne yapmak istersiniz?${NORMAL}"
    echo -e ""
    echo -e "1) Celestia Light Node Kur"
    echo -e "2) Celestia Light Node Kaldır"
    echo -e ""
    read -p "Seçiminizi girin (1/2): " choice
fi

case $choice in
    1)
        install_dependencies
        install_docker
        setup_celestia_node
        start_celestia_node
        ;;
    2)
        remove_celestia_node
        ;;
    *)
        if [ "$lang" == "EN" ]; then
            echo -e "${RED}Invalid choice. Please run the script again and choose either 1 or 2.${NORMAL}"
        else
            echo -e "${RED}Geçersiz seçim. Lütfen script'i yeniden çalıştırın ve 1 veya 2'yi seçin.${NORMAL}"
        fi
        ;;
esac
