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

IP_ADDRESS=$(hostname -I | awk '{print $1}')

if [[ -z "$IP_ADDRESS" ]]; then
    echo "⚠️ Nenhum IP correspondente à rede privada foi encontrado. Verifique a configuração de rede."
    exit 1
fi

echo "🔒 Criando rede privada Docker..."
docker network create \
    --driver bridge \
    --subnet=$SUBNET_PUBLIC \
    $DOCKER_NET_PUBLIC
echo "✅ Rede privada criada!"

echo "⚙️ Configurando roteamento de redes..."
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p

echo "📥 Clonando repositórios..."
git clone https://github.com/RTR-RapazesTechReformed/docker-compose-arrastech.git
git clone https://github.com/RTR-RapazesTechReformed/front-end-arrastech.git
git clone https://github.com/RTR-RapazesTechReformed/back-end-arrastech.git

echo "🚀 Subindo os containers com Docker Compose..."
cd docker-compose-arrastech
cp docker-compose.yml ..
cd ..
docker-compose up -d

echo "🧹 Removendo repositórios clonados..."

rm -rf docker-compose-arrastech front-end-arrastech back-end-arrastech docker-compose.yml

echo "✅ Configuração concluída!"
echo "Agora você pode rodar contêineres conectados à rede privada."

exit 0
