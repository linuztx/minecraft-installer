# Minecraft Server

This repository contains a Bash script for simplifying the installation and setup of a Minecraft server. The script automates the download process and guides users through the necessary steps to start their Minecraft server quickly and efficiently.

## Prerequisites

Before using the script, ensure that the following dependencies are installed:

- `curl`: Used for downloading server files from the internet.
- `java`: Required to run the Minecraft server. OpenJDK 21 is recommended.
- `linux`: Debian-based operating system (e.g., Ubuntu).

## Usage

To use the script, simply execute the `run.sh` file. The script will prompt you for the Minecraft server download link and the amount of RAM you want to allocate to the server. Once configured, it will download the necessary files and start the Minecraft server.

## Features

- Simplified Minecraft server installation process.
- Automatic downloading of server files.
- Customizable RAM allocation for the server.
- Customizable server properties, including world name, game mode, difficulty and online mode.
- Optional support for secure remote port forwarding using `autossh` and server session management using `tmux`.

## Limitations

- Currently supports only vanilla Minecraft server installations.
- Does not support server configuration beyond basic setup.
- Requires java to be installed; if not present, the script will prompt for installation.

## Installation

To use this script, you need to clone the repository, navigate to the directory, make the script executable, and then run it. Here are the commands you need to run:

```shellscript
git clone https://github.com/linuztx/minecraft-installer.git
cd minecraft-installer
chmod +x run.sh
./run.sh
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
