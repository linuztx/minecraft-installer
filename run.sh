#!/bin/env bash

### CREATED BY @linuztx ####
### Minecraft Server Installer ###
### Copyright (C) 2024 ###
# This script downloads, installs the Minecraft server, and starts it in a tmux session.
# Supports Debian-based systems, Alpine Linux, and Fedora. Requires curl, jq, autossh, and tmux.

# Function to install packages for Debian-based systems
install_debian_packages() {
    local packages=(curl jq autossh tmux java-21-openjdk)
    for package in "${packages[@]}"; do
        if ! command -v "$package" &>/dev/null; then
            echo -e "\n$package is not installed. Installing...\n"
            if command -v sudo &>/dev/null; then
                sudo apt install -y "$package"
            else
                apt install -y "$package"
            fi
        fi
    done
}

# Function to install packages for Alpine Linux
install_alpine_packages() {
    local packages=(curl jq autossh tmux openjdk21-jre)
    for package in "${packages[@]}"; do
        if ! command -v "$package" &>/dev/null; then
            echo -e "\n$package is not installed. Installing...\n"
            if command -v sudo &>/dev/null; then
                sudo apk add --no-interactive"$package"
            else
                apk add "$package"
            fi
        fi
    done
}

# Function to install packages for Fedora
install_fedora_packages() {
    local packages=(curl jq autossh tmux java-21-openjdk)
    for package in "${packages[@]}"; do
        if ! command -v "$package" &>/dev/null; then
            echo -e "\n$package is not installed. Installing...\n"
            if command -v sudo &>/dev/null; then
                sudo dnf install -y "$package"
            else
                dnf install -y "$package"
            fi
        fi
    done
}

install_arch_packages() {
    local packages=(curl jq autossh tmux jdk21-openjdk)
    for package in "${packages[@]}"; do
        if ! command -v "$package" &>/dev/null; then
            echo -e "\n$package is not installed. Installing...\n"
            if command -v sudo &>/dev/null; then
                sudo pacman -S --noconfirm "$package"
            else
                pacman -S --noconfirm "$package"
            fi
        fi
    done
}

# Determine the package manager and install required packages
if command -v apk &>/dev/null; then
    install_alpine_packages
elif command -v apt &>/dev/null; then
    install_debian_packages
elif command -v dnf &>/dev/null; then
    install_fedora_packages
elif command -v pacman &>/dev/null; then
    install_arch_packages
else
    echo -e "\nUnsupported operating system. This script supports Debian-based systems, Alpine Linux, and Fedora.\n"
    exit 1
fi

# Check if server.jar exists; if not, download it
if [ ! -f "$(pwd)/server.jar" ]; then
    echo "=================================================="
    echo "        @Linuztx Minecraft Server Installer       "
    echo "=================================================="
    echo "                Copyright (C) 2024                "
    echo "=================================================="
    echo "          Downloading Minecraft Server            "
    echo "=================================================="
    # Fetch the latest release version from the version manifest
    latest=$(curl -fsSL 'https://launchermeta.mojang.com/mc/game/version_manifest.json' | jq -r '.latest.release')

    # Fetch the URL for the version manifest of the latest release
    manifest_url=$(curl -fsSL 'https://launchermeta.mojang.com/mc/game/version_manifest.json' | jq -r --arg LATEST "$latest" '.versions[] | select(.id == $LATEST) | .url')

    # Fetch the server download URL from the version manifest
    latest_server=$(curl -fsSL "$manifest_url" | jq -r '.downloads.server.url')

    while true; do
        if command -v java &>/dev/null; then
            read -p "Enter your Minecraft server download link (default latest: $latest): " server
            server=${server:-"$latest_server"}
            echo -e "\nDownloading start...\n"
            curl -o "$(pwd)/server.jar" "$server"
            if [ $? -eq 0 ]; then
                echo -e "\nMinecraft server.jar successfully installed!\n"
            else
                echo -e "\nFailed to download. Make sure you have an internet connection. Aborting...\n"
                exit 0
            fi
            break
        else
            read -p "Java is not installed. Do you want to install java-21-openjdk? (yes/no): " install_java
            case $install_java in
                [yY][eE][sS])
                    if command -v sudo &>/dev/null; then
                        sudo dnf install java-21-openjdk -y
                    else
                        dnf install java-21-openjdk -y
                    fi
                    ;;
                [nN][oO])
                    echo -e "\nJava is required to run the Minecraft server. Aborting...\n"
                    exit 1
                    ;;
                *)
                    echo -e "\nInvalid input. Please enter yes or no.\n"
                    ;;
            esac
        fi
    done
fi

# Check if EULA agreement exists; if not, ask the user to accept it
if [ ! -f "$(pwd)/eula.txt" ]; then
    read -p "Do you agree to the Minecraft End User License Agreement (EULA)? (yes/no): " eula_agreement
    case $eula_agreement in
        [yY][eE][sS])
            echo "eula=true" > eula.txt
            echo -e "\nEULA agreement accepted and written to eula.txt\n"
            ;;
        *)
            echo -e "\nYou must accept Minecraft EULA to proceed with the Minecraft server installation. Aborting...\n"
            exit 0
            ;;
    esac
fi

# Prompt for server configuration if server.properties doesn't exist
if [ ! -f "$(pwd)/server.properties" ]; then
    read -p "Enter the world name (default: world): " world_name
    world_name=${world_name:-world}

    read -p "Enter the game mode (survival/creative/adventure/spectator, default: survival): " gamemode
    gamemode=${gamemode:-survival}

    read -p "Enter the difficulty (peaceful/easy/normal/hard, default: easy): " difficulty
    difficulty=${difficulty:-easy}

    read -p "Is the server online (true/false, default: true): " online_mode
    online_mode=${online_mode:-true}

    # Create server.properties with user inputs
    cat <<EOL > server.properties
#Minecraft server properties
#$(date -u)
accepts-transfers=false
allow-flight=false
allow-nether=true
broadcast-console-to-ops=true
broadcast-rcon-to-ops=true
bug-report-link=
difficulty=$difficulty
enable-command-block=false
enable-jmx-monitoring=false
enable-query=false
enable-rcon=false
enable-status=true
enforce-secure-profile=true
enforce-whitelist=false
entity-broadcast-range-percentage=100
force-gamemode=false
function-permission-level=2
gamemode=$gamemode
generate-structures=true
generator-settings={}
hardcore=false
hide-online-players=false
initial-disabled-packs=
initial-enabled-packs=vanilla
level-name=$world_name
level-seed=
level-type=minecraft\:normal
log-ips=true
max-chained-neighbor-updates=1000000
max-players=20
max-tick-time=60000
max-world-size=29999984
motd=A Minecraft Server
network-compression-threshold=256
online-mode=$online_mode
op-permission-level=4
player-idle-timeout=0
prevent-proxy-connections=false
pvp=true
query.port=25565
rate-limit=0
rcon.password=
rcon.port=25575
region-file-compression=deflate
require-resource-pack=false
resource-pack=
resource-pack-id=
resource-pack-prompt=
resource-pack-sha1=
server-ip=
server-port=25565
simulation-distance=10
spawn-animals=true
spawn-monsters=true
spawn-npcs=true
spawn-protection=16
sync-chunk-writes=true
text-filtering-config=
use-native-transport=true
view-distance=10
white-list=false
EOL
else
    # Update existing server.properties with new values
    read -p "Enter the world name (default: world): " world_name
    world_name=${world_name:-world}
    sed -i "s/^level-name=.*/level-name=$world_name/" server.properties

    read -p "Enter the game mode (survival/creative/adventure/spectator, default: survival): " gamemode
    gamemode=${gamemode:-survival}
    sed -i "s/^gamemode=.*/gamemode=$gamemode/" server.properties

    read -p "Enter the difficulty (peaceful/easy/normal/hard, default: easy): " difficulty
    difficulty=${difficulty:-easy}
    sed -i "s/^difficulty=.*/difficulty=$difficulty/" server.properties

    read -p "Is the server online (true/false, default: true): " online_mode
    online_mode=${online_mode:-true}
    sed -i "s/^online-mode=.*/online-mode=$online_mode/" server.properties

    read -p "Enter the local port to use for Minecraft server (default: 25565): " local_port
    local_port=${local_port:-25565}
    sed -i "s/^server-port=.*/server-port=$local_port/" server.properties

    read -p "Enter the remote port for autossh (default: 0): " remote_port
    remote_port=${remote_port:-0}
fi

# Start Minecraft Server
echo "=================================================="
echo "        @Linuztx Minecraft Server Installer       "
echo "=================================================="
echo "                Copyright (C) 2024                "
echo "=================================================="
echo "            Starting Minecraft Server             "
echo "=================================================="
read -p "How much maximum GB of RAM would you like to use for your Minecraft server? (default 1GB, numeric input only): " max_ram
max_ram=${max_ram:-1}
echo ""

tmux new-session -d -s minecraft "java -Xmx${max_ram}G -Xms1G -jar server.jar nogui"
tmux split-window -t minecraft "autossh -M 0 -R ${remote_port}:localhost:${local_port} serveo.net"
tmux attach

# Provide feedback on server start
if [ $? -eq 0 ]; then
    echo -e "\nMinecraft server and auto SSH were started successfully in tmux session 'minecraft'!\n"
else
    echo -e "\nFailed to start Minecraft server or auto SSH. Check logs for details.\n"
fi

