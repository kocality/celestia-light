#!/bin/bash

# Define colors and styles
RED="\033[31m"
YELLOW="\033[33m"
GREEN="\033[32m"
NORMAL="\033[0m"
BOLD="\033[1m"
ITALIC="\033[3m"

# Logfile
LOGFILE="$HOME/celestia-node.log"
MAX_LOG_SIZE=52428800  # 50MB

log_message() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >> "$LOGFILE"
}

# Rotate log file if it exceeds 50MB
rotate_log_file() {
    if [ -f "$LOGFILE" ] && [ $(stat -c%s "$LOGFILE") -ge $MAX_LOG_SIZE ]; then
        mv "$LOGFILE" "$LOGFILE.bak"
        touch "$LOGFILE"
        log_message "Log file rotated. Previous log archived as $LOGFILE.bak"
    fi
}

# Cleanup
cleanup() {
    log_message "Cleaning up temporary files and removing script..."
    rm -f "$0"  # Remove the script itself
    log_message "Cleanup completed."
}

# Languages
while true; do
    echo -e "${YELLOW}Select Language / Dil Seçiniz / 选择语言 / Choisissez la langue / Seleccione el idioma:${NORMAL}"
    echo -e "1) English"
    echo -e "2) Türkçe"
    echo -e "3) 中文"
    echo -e "4) Français"
    echo -e "5) Español"
    read -p "Enter your choice (1/2/3/4/5): " lang_choice

    case $lang_choice in
        1) lang="EN"; break ;;
        2) lang="TR"; break ;;
        3) lang="CN"; break ;;
        4) lang="FR"; break ;;
        5) lang="ES"; break ;;
        *) echo -e "${RED}Invalid choice. Please enter 1, 2, 3, 4, or 5.${NORMAL}" ;;
    esac
done

log_message "Language selected: $lang"

# Github Version API
VERSION=$(curl -s "https://api.github.com/repos/celestiaorg/celestia-node/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

# Check if VERSION is empty
if [ -z "$VERSION" ]; then
    if [ "$lang" == "EN" ]; then
        echo "Failed to fetch the latest version. Exiting."
    elif [ "$lang" == "TR" ]; then
        echo "En son sürüm alınamadı. Çıkılıyor."
    elif [ "$lang" == "CN" ]; then
        echo "无法获取最新版本。退出。"
    elif [ "$lang" == "FR" ];then
        echo "Impossible de récupérer la dernière version. Sortie."
    elif [ "$lang" == "ES" ];then
        echo "No se pudo obtener la última versión. Saliendo."
    fi
    log_message "Failed to fetch the latest version."
    cleanup
    exit 1
fi

log_message "Fetched latest version: $VERSION"

# Check if Light Node is already installed
check_existing_installation() {
    if [ -d "$HOME/my-node-store" ] || [ ! -z "$(sudo docker ps -q --filter ancestor=ghcr.io/celestiaorg/celestia-node:$VERSION)" ]; then
        if [ "$lang" == "EN" ]; then
            echo -e "${GREEN}Celestia Light Node is already installed. Aborting installation.${NORMAL}"
        elif [ "$lang" == "TR" ];then
            echo -e "${GREEN}Celestia Light Node zaten kurulu. Kurulum iptal ediliyor.${NORMAL}"
        elif [ "$lang" == "CN" ];then
            echo -e "${GREEN}Celestia轻节点已安装。安装中止。${NORMAL}"
        elif [ "$lang" == "FR" ];then
            echo -e "${GREEN}Le nœud léger Celestia est déjà installé. Annulation de l'installation.${NORMAL}"
        elif [ "$lang" == "ES" ];then
            echo -e "${GREEN}Celestia Light Node ya está instalado. Abortando la instalación.${NORMAL}"
        fi
        log_message "Celestia Light Node is already installed. Installation aborted."
        cleanup
        exit 0
    fi
}

# Remove Node
remove_celestia_node() {
    log_message "Removing Celestia Light Node..."
    NODE_ID=$(sudo docker ps -a -q --filter ancestor=ghcr.io/celestiaorg/celestia-node:$VERSION)
    if [ -n "$NODE_ID" ]; then
        sudo docker stop $NODE_ID >/dev/null 2>&1
        sudo docker rm $NODE_ID >/dev/null 2>&1
        sudo rm -rf $HOME/my-node-store
        screen -ls | grep -o '[0-9]*\.celestia-node' | awk '{print $1}' | xargs -I {} screen -S {} -X quit
        if [ "$lang" == "EN" ]; then
            echo -e "${GREEN}Celestia Light Node removed successfully.${NORMAL}"
        elif [ "$lang" == "TR" ];then
            echo -e "${GREEN}Celestia Light Node başarıyla kaldırıldı.${NORMAL}"
        elif [ "$lang" == "CN" ];then
            echo -e "${GREEN}Celestia轻节点成功移除。${NORMAL}"
        elif [ "$lang" == "FR" ];then
            echo -e "${GREEN}Le nœud léger Celestia a été supprimé avec succès.${NORMAL}"
        elif [ "$lang" == "ES" ];then
            echo -e "${GREEN}Celestia Light Node eliminado con éxito.${NORMAL}"
        fi
        log_message "Celestia Light Node removed successfully."
    else
        if [ "$lang" == "EN" ]; then
            echo -e "${YELLOW}No node found to remove.${NORMAL}"
        elif [ "$lang" == "TR" ];then
            echo -e "${YELLOW}Kaldırılacak node bulunamadı.${NORMAL}"
        elif [ "$lang" == "CN" ];then
            echo -e "${YELLOW}未找到要移除的节点。${NORMAL}"
        elif [ "$lang" == "FR" ];then
            echo -e "${YELLOW}Aucun nœud trouvé à supprimer.${NORMAL}"
        elif [ "$lang" == "ES" ];then
            echo -e "${YELLOW}No se encontró ningún nodo para eliminar.${NORMAL}"
        fi
        log_message "No node found to remove."
    fi
}

# Install system dependencies
install_dependencies() {
    log_message "Installing system updates and dependencies..."
    if [ "$lang" == "EN" ];then
        echo -e "${YELLOW}Installing System Updates and Dependencies...${NORMAL} (This may take a few minutes)"
    elif [ "$lang" == "TR" ];then
        echo -e "${YELLOW}Sistem Güncellemeleri ve Bağımlılıklar Yükleniyor...${NORMAL} (Bu birkaç dakika sürebilir)"
    elif [ "$lang" == "CN" ];then
        echo -e "${YELLOW}正在安装系统更新和依赖项...${NORMAL}（可能需要几分钟）"
    elif [ "$lang" == "FR" ];then
        echo -e "${YELLOW}Installation des mises à jour système et des dépendances...${NORMAL} (Cela peut prendre quelques minutes)"
    elif [ "$lang" == "ES" ];then
        echo -e "${YELLOW}Instalando actualizaciones del sistema y dependencias...${NORMAL} (Esto puede tardar unos minutos)"
    fi
    sudo apt update -y >/dev/null 2>&1 && sudo apt upgrade -y >/dev/null 2>&1
    sudo apt-get install -y curl tar wget aria2 clang pkg-config libssl-dev jq build-essential git make ncdu screen >/dev/null 2>&1
    if [ "$lang" == "EN" ];then
        echo -e "${GREEN}System Updates and Dependencies installed successfully.${NORMAL}"
    elif [ "$lang" == "TR" ];then
        echo -e "${GREEN}Sistem Güncellemeleri ve Bağımlılıklar başarıyla yüklendi.${NORMAL}"
    elif [ "$lang" == "CN" ];then
        echo -e "${GREEN}系统更新和依赖项已成功安装。${NORMAL}"
    elif [ "$lang" == "FR" ];then
        echo -e "${GREEN}Les mises à jour du système et les dépendances ont été installées avec succès.${NORMAL}"
    elif [ "$lang" == "ES" ];then
        echo -e "${GREEN}Actualizaciones del sistema y dependencias instaladas con éxito.${NORMAL}"
    fi
    log_message "System updates and dependencies installed successfully."
}

# Install docker
install_docker() {
    log_message "Checking for Docker installation..."
    if ! command -v docker &> /dev/null; then
        if [ "$lang" == "EN" ];then
            echo -e "${YELLOW}Installing Docker...${NORMAL}"
                elif [ "$lang" == "TR" ];then
            echo -e "${YELLOW}Docker Yükleniyor...${NORMAL}"
        elif [ "$lang" == "CN" ];then
            echo -e "${YELLOW}正在安装Docker...${NORMAL}"
        elif [ "$lang" == "FR" ];then
            echo -e "${YELLOW}Installation de Docker...${NORMAL}"
        elif [ "$lang" == "ES" ];then
            echo -e "${YELLOW}Instalando Docker...${NORMAL}"
        fi
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update >/dev/null 2>&1
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io >/dev/null 2>&1
        sudo docker run hello-world >/dev/null 2>&1
        if [ "$lang" == "EN" ];then
            echo -e "${GREEN}Docker installed successfully.${NORMAL}"
        elif [ "$lang" == "TR" ];then
            echo -e "${GREEN}Docker başarıyla yüklendi.${NORMAL}"
        elif [ "$lang" == "CN" ];then
            echo -e "${GREEN}Docker安装成功。${NORMAL}"
        elif [ "$lang" == "FR" ];then
            echo -e "${GREEN}Docker installé avec succès.${NORMAL}"
        elif [ "$lang" == "ES" ];then
            echo -e "${GREEN}Docker instalado con éxito.${NORMAL}"
        fi
        log_message "Docker installed successfully."
    else
        if [ "$lang" == "EN" ];then
            echo -e "${GREEN}Docker is already installed.${NORMAL}"
        elif [ "$lang" == "TR" ];then
            echo -e "${GREEN}Docker zaten yüklü.${NORMAL}"
        elif [ "$lang" == "CN" ];then
            echo -e "${GREEN}Docker已经安装。${NORMAL}"
        elif [ "$lang" == "FR" ];then
            echo -e "${GREEN}Docker est déjà installé.${NORMAL}"
        elif [ "$lang" == "ES" ];then
            echo -e "${GREEN}Docker ya está instalado.${NORMAL}"
        fi
        log_message "Docker is already installed."
    fi
}

setup_celestia_node() {
    log_message "Setting up Celestia Light Node..."
    if [ "$lang" == "EN" ];then
        echo -e "${YELLOW}Setting up Celestia Light Node...${NORMAL}"
    elif [ "$lang" == "TR" ];then
        echo -e "${YELLOW}Celestia Light Node kuruluyor...${NORMAL}"
    elif [ "$lang" == "CN" ];then
        echo -e "${YELLOW}正在设置Celestia轻节点...${NORMAL}"
    elif [ "$lang" == "FR" ];then
        echo -e "${YELLOW}Configuration du nœud léger Celestia...${NORMAL}"
    elif [ "$lang" == "ES" ];then
        echo -e "${YELLOW}Configurando Celestia Light Node...${NORMAL}"
    fi
    export NETWORK=celestia
    export NODE_TYPE=light
    export RPC_URL=http://public-celestia-consensus.numia.xyz

    cd $HOME
    mkdir -p my-node-store
    sudo chown 10001:10001 $HOME/my-node-store

    if [ "$lang" == "EN" ];then
        echo -e "${YELLOW}Initializing Celestia Light Node...${NORMAL}"
    elif [ "$lang" == "TR" ];then
        echo -e "${YELLOW}Celestia Light Node başlatılıyor...${NORMAL}"
    elif [ "$lang" == "CN" ];then
        echo -e "${YELLOW}正在初始化Celestia轻节点...${NORMAL}"
    elif [ "$lang" == "FR" ];then
        echo -e "${YELLOW}Initialisation du nœud léger Celestia...${NORMAL}"
    elif [ "$lang" == "ES" ];then
        echo -e "${YELLOW}Inicializando Celestia Light Node...${NORMAL}"
    fi
    OUTPUT=$(sudo docker run -e NODE_TYPE=$NODE_TYPE -e P2P_NETWORK=$NETWORK \
        -v $HOME/my-node-store:/home/celestia \
        ghcr.io/celestiaorg/celestia-node:$VERSION \
        celestia light init --p2p.network $NETWORK)

    if [ "$lang" == "EN" ];then
        echo -e "${RED}Please save your wallet information and mnemonics securely.${NORMAL}"
        echo -e "${RED}NAME and ADDRESS:${NORMAL}"
        echo -e "${NORMAL}$(echo "$OUTPUT" | grep -E 'NAME|ADDRESS')${NORMAL}"
        echo -e "${RED}MNEMONIC (save this somewhere safe!!!):${NORMAL}"
        echo -e "${NORMAL}$(echo "$OUTPUT" | sed -n '/MNEMONIC (save this somewhere safe!!!):/,$p' | tail -n +2)${NORMAL}"
        echo -e "${RED}This information will not be saved automatically. Make sure to record it manually.${NORMAL}"
    elif [ "$lang" == "TR" ];then
        echo -e "${RED}Cüzdan bilgilerinizi ve mnemoniclerinizi güvenli bir şekilde kaydedin.${NORMAL}"
        echo -e "${RED}İSİM ve ADRES:${NORMAL}"
        echo -e "${NORMAL}$(echo "$OUTPUT" | grep -E 'NAME|ADDRESS')${NORMAL}"
        echo -e "${RED}MNEMONIC (bunu güvenli bir yere kaydedin!!!):${NORMAL}"
        echo -e "${NORMAL}$(echo "$OUTPUT" | sed -n '/MNEMONIC (save this somewhere safe!!!):/,$p' | tail -n +2)${NORMAL}"
        echo -e "${RED}Bu bilgiler otomatik olarak kaydedilmeyecek. Kaydettiğinizden emin olun.${NORMAL}"
    elif [ "$lang" == "CN" ];then
        echo -e "${RED}请妥善保存您的钱包信息和助记符。${NORMAL}"
        echo -e "${RED}姓名和地址:${NORMAL}"
        echo -e "${NORMAL}$(echo "$OUTPUT" | grep -E 'NAME|ADDRESS')${NORMAL}"
        echo -e "${RED}助记符（请保存到安全的地方!!!）:${NORMAL}"
        echo -e "${NORMAL}$(echo "$OUTPUT" | sed -n '/MNEMONIC (save this somewhere safe!!!):/,$p' | tail -n +2)${NORMAL}"
        echo -e "${RED}此信息不会自动保存。请确保手动记录。${NORMAL}"
    elif [ "$lang" == "FR" ];then
        echo -e "${RED}Veuillez enregistrer vos informations de portefeuille et vos mnémoniques en toute sécurité.${NORMAL}"
        echo -e "${RED}NOM et ADRESSE:${NORMAL}"
        echo -e "${NORMAL}$(echo "$OUTPUT" | grep -E 'NAME|ADDRESS')${NORMAL}"
        echo -e "${RED}MNEMONIQUE (enregistrez ceci quelque part en sécurité!!!):${NORMAL}"
        echo -e "${NORMAL}$(echo "$OUTPUT" | sed -n '/MNEMONIC (save this somewhere safe!!!):/,$p' | tail -n +2)${NORMAL}"
        echo -e "${RED}Ces informations ne seront pas enregistrées automatiquement. Assurez-vous de les noter manuellement.${NORMAL}"
    elif [ "$lang" == "ES" ];then
        echo -e "${RED}Por favor, guarde su información de billetera y mnemonics de manera segura.${NORMAL}"
        echo -e "${RED}NOMBRE y DIRECCIÓN:${NORMAL}"
        echo -e "${NORMAL}$(echo "$OUTPUT" | grep -E 'NAME|ADDRESS')${NORMAL}"
        echo -e "${RED}MNEMONIC (guarde esto en un lugar seguro!!!):${NORMAL}"
        echo -e "${NORMAL}$(echo "$OUTPUT" | sed -n '/MNEMONIC (save this somewhere safe!!!):/,$p' | tail -n +2)${NORMAL}"
        echo -e "${RED}Esta información no se guardará automáticamente. Asegúrese de registrarla manualmente.${NORMAL}"
    fi

    log_message "Celestia Light Node initialized."

    while true; do
        if [ "$lang" == "EN" ];then
            read -p "Did you save your wallet information and mnemonics? (yes/no): " yn
        elif [ "$lang" == "TR" ];then
            read -p "Cüzdan bilgilerinizi ve mnemonic'lerinizi kaydettiniz mi? (evet/hayır): " yn
        elif [ "$lang" == "CN" ];then
            read -p "您保存了钱包信息和助记符吗？（是/否）： " yn
                elif [ "$lang" == "FR" ];then
            read -p "Avez-vous enregistré vos informations de portefeuille et vos mnémoniques ? (oui/non) : " yn
        elif [ "$lang" == "ES" ];then
            read -p "¿Ha guardado su información de billetera y mnemonics? (sí/no): " yn
        fi
        case $yn in
            [Yy]* | [Ee]* | [是]* | [Oo]* | [Ss]*)
                log_message "User confirmed that wallet information and mnemonics were saved."
                break
                ;;
            [Nn]* | [Hh]* | [否]* | [Nn]*)
                if [ "$lang" == "EN" ];then
                    echo -e "${RED}Please save your wallet information and mnemonics before continuing.${NORMAL}"
                elif [ "$lang" == "TR" ];then
                    echo -e "${RED}Lütfen devam etmeden önce cüzdan bilgilerinizi ve mnemonic'lerinizi kaydedin.${NORMAL}"
                elif [ "$lang" == "CN" ];then
                    echo -e "${RED}请在继续之前保存您的钱包信息和助记符。${NORMAL}"
                elif [ "$lang" == "FR" ];then
                    echo -e "${RED}Veuillez enregistrer vos informations de portefeuille et vos mnémoniques avant de continuer.${NORMAL}"
                elif [ "$lang" == "ES" ];then
                    echo -e "${RED}Por favor, guarde su información de billetera y mnemonics antes de continuar.${NORMAL}"
                fi
                ;;
            *)
                if [ "$lang" == "EN" ];then
                    echo "Please answer yes or no."
                elif [ "$lang" == "TR" ];then
                    echo "Lütfen evet ya da hayır cevabı verin."
                elif [ "$lang" == "CN" ];then
                    echo "请回答是或否。"
                elif [ "$lang" == "FR" ];then
                    echo "Veuillez répondre par oui ou non."
                elif [ "$lang" == "ES" ];then
                    echo "Por favor, responda sí o no."
                fi
                ;;
        esac
    done
}

start_celestia_node() {
    log_message "Starting Celestia Light Node..."
    if [ "$lang" == "EN" ];then
        echo -e "${YELLOW}Starting Celestia Light Node...${NORMAL}"
    elif [ "$lang" == "TR" ];then
        echo -e "${YELLOW}Celestia Light Node başlatılıyor...${NORMAL}"
    elif [ "$lang" == "CN" ];then
        echo -e "${YELLOW}正在启动Celestia轻节点...${NORMAL}"
    elif [ "$lang" == "FR" ];then
        echo -e "${YELLOW}Démarrage du nœud léger Celestia...${NORMAL}"
    elif [ "$lang" == "ES" ];then
        echo -e "${YELLOW}Iniciando Celestia Light Node...${NORMAL}"
    fi

    screen -S celestia-node -dm bash -c "sudo docker run -e NODE_TYPE=$NODE_TYPE -e P2P_NETWORK=$NETWORK \
        -v $HOME/my-node-store:/home/celestia \
        ghcr.io/celestiaorg/celestia-node:$VERSION \
        celestia light start --core.ip $RPC_URL --p2p.network $NETWORK"

    if [ "$lang" == "EN" ];then
        echo -e "${GREEN}Celestia Light Node started successfully.${NORMAL}"
        echo -e "${YELLOW}To view the logs, use: screen -r celestia-node${NORMAL}"
        echo -e "${YELLOW}To detach from screen, press Ctrl+A, then D.${NORMAL}"
    elif [ "$lang" == "TR" ];then
        echo -e "${GREEN}Celestia Light Node başarıyla başlatıldı.${NORMAL}"
        echo -e "${YELLOW}Logları görmek için: screen -r celestia-node${NORMAL}"
        echo -e "${YELLOW}Screen'den çıkmak için, Ctrl+A, sonra D tuşlarına basın.${NORMAL}"
    elif [ "$lang" == "CN" ];then
        echo -e "${GREEN}Celestia轻节点启动成功。${NORMAL}"
        echo -e "${YELLOW}要查看日志，请使用：screen -r celestia-node${NORMAL}"
        echo -e "${YELLOW}要从screen中退出，请按Ctrl+A，然后按D。${NORMAL}"
    elif [ "$lang" == "FR" ];then
        echo -e "${GREEN}Le nœud léger Celestia a démarré avec succès.${NORMAL}"
        echo -e "${YELLOW}Pour voir les journaux, utilisez : screen -r celestia-node${NORMAL}"
        echo -e "${YELLOW}Pour détacher l'écran, appuyez sur Ctrl+A, puis D.${NORMAL}"
    elif [ "$lang" == "ES" ];then
        echo -e "${GREEN}Celestia Light Node iniciado con éxito.${NORMAL}"
        echo -e "${YELLOW}Para ver los registros, use: screen -r celestia-node${NORMAL}"
        echo -e "${YELLOW}Para salir de screen, presione Ctrl+A, luego D.${NORMAL}"
    fi

    log_message "Celestia Light Node started successfully."

    echo -e "${GREEN}
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⣿⣿⠁⠀⠀⠀⠀⠀⠀⠀⢀⣼⣿⣿⣿⠇⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⠀⠀⠀⠀⠀⣀⡀⣤⣾⣿⣿⣿⠏⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⣿⣿⣿⠀⢀⣤⠄⣈⡉⠇⣿⣿⣿⡿⠋⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⡿⢀⣿⣿⠀⣿⣿⡶⠟⢉⣉⣀⣀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⣀⠀⠀⣸⣿⣿⣿⠇⣸⣿⣿⣇⠘⡟⢁⡴⣿⣿⠿⢿⣷⣄⠀⠀
⠀⠀⠀⠀⢠⣾⠀⢲⣿⣿⣿⣿⣿⠀⣿⣿⣿⣿⣆⠀⠀⣃⠿⢿⣐⠀⣻⣿⡄⠀
⠀⠀⠀⠀⣾⣿⣇⠈⢿⣿⣿⣿⣿⠀⢹⢿⣿⣿⣿⣦⢸⣿⣶⣾⣿⣿⣿⣿⠃⠀
⠀⠀⣴⡇⢻⣿⣿⣦⡀⠹⣿⣿⣿⡆⠈⠘⣿⣿⣿⣿⣷⣿⣿⣿⣿⣿⣿⡟⠀⠀
⠀⢸⣿⡇⠘⣿⣿⣿⣿⣦⣀⠉⠁⠀⣠⣤⣈⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠇⠀⠀
⠀⢸⣿⣷⡀⠹⣿⣿⣿⣿⣿⣷⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⠀⠀⠀
⠀⢸⣿⣿⣷⡀⠹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠁⠀⠀⠀
⠀⢸⣿⣿⣿⣷⣄⠘⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠋⠀⠀⠀⠀⠀
⠀⢸⣿⣿⣿⣿⣿⠁⠀⠈⠙⠛⠿⠿⠿⠿⠿⠟⠛⠋⠉⠜⠋⠀⠀⠀⠀⠀⠀⠀
 ${NORMAL}"
}

clear

echo -e "${GREEN}
 _                   _ _ _         
| | _____   ___ __ _| (_) |_ _   _ 
| |/ / _ \ / __/ _\` | | | __| | | |
|   < (_) | (_| (_| | | | |_| |_| |
|_|\_\___/ \___\__,_|_|_|\__|\__, |
                             |___/ 
${NORMAL}" | tee -a "$LOGFILE"

if [ "$lang" == "EN" ];then
    echo -e "${GREEN}${BOLD}${ITALIC}Welcome to the one-command script for Celestia Light Node!${NORMAL}"
    echo -e ""
    echo -e "${GREEN}${BOLD}${ITALIC}This script was made with love by ${BOLD}@kkocality <3${NORMAL}"
    echo -e "${GREEN}${BOLD}${ITALIC}For more: kocality.com${NORMAL}"
elif [ "$lang" == "TR" ];then
    echo -e "${GREEN}${BOLD}${ITALIC}Celestia Light Node için tek komutluk script'e hoş geldiniz!${NORMAL}"
    echo -e ""
    echo -e "${GREEN}${BOLD}${ITALIC}Bu script @kkocality tarafından sevgiyle yapıldı <3${NORMAL}"
    echo -e "${GREEN}${BOLD}${ITALIC}Daha fazlası için: kocality.com${NORMAL}"
elif [ "$lang" == "CN" ];then
    echo -e "${GREEN}${BOLD}${ITALIC}欢迎使用Celestia轻节点的一键脚本！${NORMAL}"
    echo -e ""
    echo -e "${GREEN}${BOLD}${ITALIC}这个脚本由@kkocality用爱制作 <3${NORMAL}"
    echo -e "${GREEN}${BOLD}${ITALIC}更多信息请访问: kocality.com${NORMAL}"
elif [ "$lang" == "FR" ];then
    echo -e "${GREEN}${BOLD}${ITALIC}Bienvenue dans le script en une commande pour Celestia Light Node !${NORMAL}"
    echo -e ""
    echo -e "${GREEN}${BOLD}${ITALIC}Ce script a été fait avec amour par ${BOLD}@kkocality <3${NORMAL}"
    echo -e "${GREEN}${BOLD}${ITALIC}Pour plus d'informations: kocality.com${NORMAL}"
elif [ "$lang" == "ES" ];then
    echo -e "${GREEN}${BOLD}${ITALIC}¡Bienvenido al script de un solo comando para Celestia Light Node!${NORMAL}"
    echo -e ""
    echo -e "${GREEN}${BOLD}${ITALIC}Este script fue hecho con amor por ${BOLD}@kkocality <3${NORMAL}"
    echo -e "${GREEN}${BOLD}${ITALIC}Para más información: kocality.com${NORMAL}"
fi

log_message "Script started."

sleep 7

while true; do
    if [ "$lang" == "EN" ];then
        echo -e "${YELLOW}What would you like to do?"
        echo -e ""
        echo -e "1) Setup Celestia Light Node"
        echo -e "2) Remove Celestia Light Node"
        echo -e ""
        read -p "Enter your choice (1/2): " choice
    elif [ "$lang" == "TR" ];then
        echo -e "${YELLOW}Ne yapmak istersiniz?${NORMAL}"
        echo -e ""
        echo -e "1) Celestia Light Node Kur"
        echo -e "2) Celestia Light Node Kaldır"
        echo -e ""
        read -p "Seçiminizi girin (1/2): " choice
    elif [ "$lang" == "CN" ];then
        echo -e "${YELLOW}您想做什么？${NORMAL}"
        echo -e ""
        echo -e "1) 安装Celestia轻节点"
        echo -e "2) 移除Celestia轻节点"
        echo -e ""
        read -p "请输入您的选择（1/2）： " choice
    elif [ "$lang" == "FR" ];then
        echo -e "${YELLOW}Que voulez-vous faire?${NORMAL}"
        echo -e ""
        echo -e "1) Configurer Celestia Light Node"
        echo -e "2) Supprimer Celestia Light Node"
        echo -e ""
        read -p "Entrez votre choix (1/2) : " choice
    elif [ "$lang" == "ES" ];then
        echo -e "${YELLOW}¿Qué le gustaría hacer?${NORMAL}"
        echo -e ""
        echo -e "1) Configurar Celestia Light Node"
        echo -e "2) Eliminar Celestia Light Node"
        echo -e ""
        read -p "Ingrese su elección (1/2): " choice
    fi

    case $choice in
        1)
            check_existing_installation
            install_dependencies
            install_docker
            setup_celestia_node
            start_celestia_node
            break
            ;;
        2)
            remove_celestia_node
            break
            ;;
        *)
            if [ "$lang" == "EN" ];then
                echo -e "${RED}Invalid choice. Please enter 1 or 2.${NORMAL}"
            elif [ "$lang" == "TR" ];then
                echo -e "${RED}Geçersiz seçim. Lütfen 1 veya 2'yi girin.${NORMAL}"
            elif [ "$lang" == "CN" ];then
                echo -e "${RED}无效选择。请输入1或2。${NORMAL}"
            elif [ "$lang" == "FR" ];then
                echo -e "${RED}Choix invalide. Veuillez entrer 1 ou 2.${NORMAL}"
            elif [ "$lang" == "ES" ];then
                echo -e "${RED}Elección no válida. Por favor, ingrese 1 o 2.${NORMAL}"
            fi
            ;;
    esac
done

log_message "Script execution completed."
cleanup
