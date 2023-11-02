#!/bin/bash

# Hole die Ubuntu-Version
UBUNTU_VERSION=$(lsb_release -rs)

# Zabbix Agent 7.0 Versions-URL
ZABBIX_AGENT_URL="https://repo.zabbix.com/zabbix/6.5/ubuntu/pool/main/z/zabbix-release"

# Wähle das passende Paket abhängig von der Ubuntu-Version
if [[ $UBUNTU_VERSION == "22.04" ]]; then
    PACKAGE_URL="${ZABBIX_AGENT_URL}/zabbix-release_6.5-1+ubuntu22.04_all.deb"
elif [[ $UBUNTU_VERSION == "20.04" ]]; then
    PACKAGE_URL="${ZABBIX_AGENT_URL}/zabbix-release_6.5-1+ubuntu20.04_all.deb"
elif [[ $UBUNTU_VERSION == "18.04" ]]; then
    PACKAGE_URL="${ZABBIX_AGENT_URL}/zabbix-release_6.5-1+ubuntu18.04_all.deb"
elif [[ $UBUNTU_VERSION == "16.04" ]]; then
    PACKAGE_URL="${ZABBIX_AGENT_URL}/zabbix-release_6.5-1+ubuntu16.04_all.deb"
elif [[ $UBUNTU_VERSION == "14.04" ]]; then
    PACKAGE_URL="${ZABBIX_AGENT_URL}/zabbix-release_6.5-1+ubuntu14.04_all.deb"
else
    echo "Unsupported Ubuntu version: ${UBUNTU_VERSION}"
    exit 1
fi

# Downloade und installiere das Zabbix-Agent-Paket
wget -O zabbix-release.deb "$PACKAGE_URL" && \
sudo dpkg -i zabbix-release.deb && \
sudo rm zabbix-release.deb && \
sudo apt update

# Uninstall Zabbix-Agent
sudo apt purge -y zabbix-agent2 zabbix-agent
rm -r /etc/zabbix

# Installiere Zabbix-Agent2
sudo apt install -y zabbix-agent2

# Backup der Original zabbix_agent2.conf
sudo cp /etc/zabbix/zabbix_agent2.conf /etc/zabbix/zabbix_agent2.conf.backup

# Abfrage von Server und Hostname
read -p "Enter Zabbix Server or Zabbix Proxy IP/Hostname: " ZABBIX_SERVER_IP
read -p "Enter Hostname for this agent: " ZABBIX_HOSTNAME

# Update der Konfigurationsdatei
sudo sed -i "s/Server=127.0.0.1/Server=$ZABBIX_SERVER_IP/" /etc/zabbix/zabbix_agent2.conf
sudo sed -i "s/ServerActive=127.0.0.1/ServerActive=$ZABBIX_SERVER_IP:10051/" /etc/zabbix/zabbix_agent2.conf
sudo sed -i "s/Hostname=Zabbix server/Hostname=$ZABBIX_HOSTNAME/" /etc/zabbix/zabbix_agent2.conf

# Set UFW Firewall
sudo ufw allow from $ZABBIX_SERVER_IP to any port 10050:10051 proto tcp comment 'Zabbix Agent'

# Starte und aktiviere den Zabbix-Agenten
sudo systemctl restart zabbix-agent2
sudo systemctl enable zabbix-agent2

echo "Zabbix Agent 2 wurde erfolgreich installiert und konfiguriert."
