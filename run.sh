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
    while true; do
        if command -v java &>/dev/null; then
            read -p "Enter your Minecraft server download link (default:1.20.6): " server
            server=${server:-"https://piston-data.mojang.com/v1/objects/145ff0858209bcfc164859ba735d4199aafa1eea/server.jar"}
            echo -e "\nDownloading start...\n"
            wget -O "$(pwd)/server.jar" "$server"
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
                    else
                        apt update -y
                        apt install openjdk-21-jre -y
                    fi
                    break
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
read -p "How much GB of RAM would you like to use for your Minecraft server? (default 1GB, numeric input only): " ram
ram=${ram:-'1'}
echo ""

java -Xmx${ram}G -Xms${ram}G -jar server.jar nogui

# Provide feedback on server start
if [ $? -eq 0 ]; then
    echo -e "\nMinecraft server was started successfully!\n"
else
    echo -e "\nFailed to start Minecraft server. Check logs for details.\n"
fi
