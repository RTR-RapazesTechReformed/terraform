#!/bin/bash

DOCKER_NET_PUBLIC="minha-rede-publica"
SUBNET_PUBLIC="10.0.0.0/24"

if [ "$(id -u)" -ne 0 ]; then
    echo "Por favor, execute como root ou usando sudo."
    exit 1
fi

sudo apt update -y && sudo apt upgrade -y

if ! command -v git &> /dev/null; then
    echo "🐱 Instalando Git..."
    sudo apt install git -y
else
    echo "✅ Git já está instalado."
fi

echo "✅ Git instalado com sucesso!"

if ! command -v docker &> /dev/null; then
    echo "🐋 Instalando Docker..."
    sudo apt install docker.io -y
    sudo systemctl start docker
    sudo systemctl enable docker
else
    echo "✅ Docker já está instalado."
fi

echo "✅ Docker instalado com sucesso!"

if ! command -v docker-compose &> /dev/null; then
    echo "🐋 Instalando Docker Compose..."
    sudo apt install docker-compose -y
else
    echo "✅ Docker Compose já está instalado."
fi

IP_ADDRESS=$(hostname -I | awk '{print $1}')

if [[ $IP_ADDRESS == 10.0.0.* ]]; then
    echo "🌍 Criando rede pública Docker..."
    docker network create \
        --driver bridge \
        --subnet=$SUBNET_PUBLIC \
        $DOCKER_NET_PUBLIC
    echo "✅ Rede pública criada!"
else
    echo "⚠️ O IP não corresponde à rede pública configurada. Verifique a subrede."
    exit 1
fi

echo "⚙️ Configurando roteamento de redes..."
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p

echo "✅ Configuração concluída!"
echo "Agora você pode rodar contêineres conectados à rede pública."

echo "📥 Clonando repositórios..."
git clone https://github.com/seu-usuario/docker-compose-repo.git
git clone https://github.com/seu-usuario/frontend-repo.git
git clone https://github.com/seu-usuario/backend-repo.git

echo "🚀 Subindo os containers com Docker Compose..."
cd docker-compose-repo
# CONTINUAR A PARTIR DE COPY, TODO: preciso copiar o compose para fora, aí utilizo a raiz para os caminhos
docker-compose up -d

echo "🧹 Removendo repositórios clonados..."
cd ..
rm -rf docker-compose-repo frontend-repo backend-repo docker-compose

echo "✅ Ambiente configurado com sucesso!"

exit 0
