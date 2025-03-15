#!/bin/bash

DOCKER_NET_PUBLIC="minha-rede-publica"
SUBNET_PUBLIC="10.0.0.0/24"

if [ "$(id -u)" -ne 0 ]; then
    echo "Por favor, execute como root ou usando sudo."
    exit 1
fi

sudo apt update -y && sudo apt upgrade -y

if ! command git -v  &> /dev/null; then
    echo "🐱 Instalando Git..."
    sudo apt install git -y
else
    echo "✅ Git já está instalado."
fi

echo "✅ Git instalado com sucesso!"

if ! command docker -v  &> /dev/null; then
    echo "🐋 Instalando Docker..."
    sudo apt update -y && apt install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
    echo "✅ Docker instalado com sucesso!"
else
    echo "✅ Docker já está instalado."
fi

echo "✅ Docker instalado com sucesso!"

if ! command docker-compose -v &> /dev/null; then
    echo "🐋 Instalando Docker Compose..."
    sudo apt install docker-compose -y
else
    echo "✅ Docker Compose já está instalado."
fi

echo "🚀 Inicializando Docker Swarm..."
sudo docker swarm init --advertise-addr $(hostname -I | awk '{print $1}')

# Pega o token para adicionar workers (use esse token na EC2 privada)
SWARM_JOIN_CMD=$(sudo docker swarm join-token worker -q)
echo "TOKEN_SWARM_WORKER=$SWARM_JOIN_CMD" > /tmp/swarm_token.txt
echo "✅ Cluster Swarm criado!"

echo "🌐 Criando rede overlay..."
sudo docker network create --driver overlay minha-rede

echo "📥 Clonando repositórios..."
git clone --branch feat/docker-swarm https://github.com/RTR-RapazesTechReformed/docker-compose-arrastech.git
git clone --branch feat/docker-swarm https://github.com/RTR-RapazesTechReformed/front-end-arrastech.git
git clone --branch feat/docker-swarm https://github.com/RTR-RapazesTechReformed/back-end-arrastech.git

echo "🚀 Subindo os containers com Docker Compose..."
cd docker-compose-arrastech
cp docker-compose.yml ..
cd ..
sudo docker stack deploy -c docker-compose.yml techpoints

echo "🧹 Removendo repositórios clonados..."

rm -rf docker-compose-arrastech front-end-arrastech back-end-arrastech docker-compose.yml

echo "✅ Configuração concluída!"
echo "Agora você pode rodar contêineres conectados à rede privada."

exit 0
