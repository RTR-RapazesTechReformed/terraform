#!/bin/bash

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

#echo "📥 Obtendo token do Swarm..."
#TOKEN_SWARM_WORKER=$(cat /tmp/swarm_token.txt)
#docker swarm join --token $TOKEN_SWARM_WORKER <IP_DA_EC2_PUBLICA>:2377 #IP Privado EC2 Publica

echo "✅ Nó worker adicionado ao cluster!"
#echo "✅ Configuração concluída!"
#echo "Agora você pode rodar contêineres conectados à rede privada."

echo "📥 Clonando repositório..."
git clone https://github.com/RTR-RapazesTechReformed/bd-arrastech.git

echo "🚀 Subindo container MySQL..."
cd bd-arrastech
cp sql_data.sql ..
cp Dockerfile ..
cd ..
sudo docker build -t bd-arrastech .

sudo docker run -d --name bd-arrastech --restart on-failure -p 3306:3306 bd-arrastech

echo "🧹 Removendo repositório clonado..."

rm -rf  bd-arrastech

echo "✅ Ambiente configurado com sucesso!"

exit 0
