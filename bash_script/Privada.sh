#!/bin/bash

DOCKER_NET_PRIVATE="minha-rede-privada"
SUBNET_PRIVATE="10.0.1.0/24"

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

IP_ADDRESS=$(hostname -I | awk '{print $1}')

if [[ $IP_ADDRESS == 10.0.1.* ]]; then
    echo "🔒 Criando rede privada Docker..."
    sudo docker network create \
        --driver bridge \
        --subnet=$SUBNET_PRIVATE \
        $DOCKER_NET_PRIVATE
    echo "✅ Rede privada criada!"
else
    echo "⚠️ O IP não corresponde à rede privada configurada. Verifique a subrede."
    exit 1
fi

echo "⚙️ Configurando roteamento de redes..."
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sudo sysctl -p

echo "✅ Configuração concluída!"
echo "Agora você pode rodar contêineres conectados à rede privada."

echo "📥 Clonando repositório..."
git clone https://github.com/RTR-RapazesTechReformed/bd-arrastech.git

echo "🚀 Subindo container com Dockerfile..."
cd bd-arrastech
cp sql_data.sql ..
cp Dockerfile ..
cd ..
sudo docker build -t bd-arrastech .
docker run -d --name bd-arrastech -p 3306:3306 bd-arrastech

echo "🧹 Removendo repositório clonado..."

rm -rf  bd-arrastech

echo "✅ Ambiente configurado com sucesso!"

exit 0
