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

echo "📥 Clonando repositórios..."
git clone https://github.com/RTR-RapazesTechReformed/cynthias-codex-edu.git

echo "🚀 Subindo os containers com Docker Compose..."
cd cynthias-codex-edu
cp -r * ..
cd ..
sudo docker-compose up --build -d

echo "🧹 Removendo repositórios clonados..."

rm -rf cynthias-codex-edu docker-compose.yml Dockerfile

echo "✅ Configuração concluída!"
echo "Agora você pode rodar contêineres conectados à rede privada."

exit 0
