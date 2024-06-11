#!/bin/bash

### CREATED BY @Linuztuxx ####
### Minecraft Server Installer ###
### 2024 ###
# This script downloads and install Minecraft server with ease
# Made for Minecraft players


# Check if server.jar exists; if not, download it
if [ ! -f "$(pwd)/server.jar" ]; then
    echo "=================================================="
    echo "      @Linuztuxx Minecraft Server Installer       "
    echo "=================================================="
    echo "                @Copyright 2024                   "
    echo "=================================================="
    if ! command -v curl &>/dev/null; then
        echo -e "\nCurl is not installed. Installing...\n"
            if command -v sudo &>/dev/null; then
                sudo apt update
                sudo apt install -y curl
                echo ""
            else
                apt update
                apt install -y curl
                echo ""
            fi
    fi

    if ! command -v jq &>/dev/null; then
        echo -e "\nCurl is not installed. Installing...\n"
            if command -v sudo &>/dev/null; then
                sudo apt update
                sudo apt install -y jq
                echo ""
            else
                apt update
                apt install -y jq
                echo ""
            fi
    fi

    # Fetch the latest release version from the version manifest
    latest=$(curl -fsSL 'https://launchermeta.mojang.com/mc/game/version_manifest.json' | jq -r '.latest.release')

    # Fetch the URL for the version manifest of the latest release
    manifest_url=$(curl -fsSL 'https://launchermeta.mojang.com/mc/game/version_manifest.json' | jq -r --arg LATEST "$latest" '.versions[] | select(.id == $LATEST) | .url')

    # Fetch the server download URL from the version manifest
    latest_server=$(curl -fsSL "$manifest_url" | jq -r '.downloads.server.url')

    while true; do
        if command -v java &>/dev/null; then
            read -p "Enter your Minecraft server download link (latest:$latest): " server
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
            read -p "Java is not installed. Do you want to install openjdk-21-jre? (yes/no): " install_java
            case $install_java in
                [yY][eE][sS])
                    if command -v sudo &>/dev/null; then
                        sudo apt update -y
                        sudo apt install openjdk-21-jre -y
                        echo ""
                    else
                        apt update -y
                        apt install openjdk-21-jre -y
                        echo ""
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
    read -p "Do you agree to the Minecraft End User License Agreement (EULA)? (yes/no): " eula_aggrement
    case $eula_aggrement in
        [yY][eE][sS])
            java -Xmx1024M -Xms1024M -jar server.jar nogui
            echo "eula=true" > eula.txt
            echo -e "\nEULA agreement accepted and writen to eula.txt\n"
            ;;
        *)
            echo -e "\nYou must accept Minecraft EULA to proceed with the Minecraft server installation, Aborting...\n"
            exit 0
            ;;
    esac
fi

# Start Minecraft Server
echo "=================================================="
echo "      @Linuztuxx Minecraft Server Installer       "
echo "=================================================="
echo "                @Copyright 2024                   "
echo "=================================================="
echo "           Starting Minecraft Server              "
echo "=================================================="
read -p "How much maximum GB of RAM would you like to use for your Minecraft server? (default 1GB, numeric input only): " max_ram
max_ram=${max_ram:-'1'}
echo ""

java -Xmx${max_ram}G -Xms1G -jar server.jar nogui

# Provide feedback on server start
if [ $? -eq 0 ]; then
    echo -e "\nMinecraft server was started successfully!\n"
else
    echo -e "\nFailed to start Minecraft server. Check logs for details.\n"
fi
