#!/bin/bash

DOCKER_NET_PRIVATE="minha-rede-privada"
SUBNET_PRIVATE="10.0.1.0/24"

if [ "$(id -u)" -ne 0 ]; then
    echo "Por favor, execute como root ou usando sudo."
    exit 1
fi

if ! command -v git &> /dev/null; then
    echo "🐱 Instalando Git..."
    sudo apt install git -y
else
    echo "✅ Git já está instalado."
fi

echo "🐋 Instalando Docker..."

apt update -y && apt install -y docker.io

systemctl start docker
systemctl enable docker

echo "✅ Docker instalado com sucesso!"

IP_ADDRESS=$(hostname -I | awk '{print $1}')

if [[ $IP_ADDRESS == 10.0.1.* ]]; then
    echo "🔒 Criando rede privada Docker..."
    docker network create \
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
sysctl -p

echo "✅ Configuração concluída!"
echo "Agora você pode rodar contêineres conectados à rede privada."

echo "📥 Clonando repositório..."
git clone https://github.com/RTR-RapazesTechReformed/bd-arrastech.git

echo "🚀 Subindo container com Dockerfile..."
cd bd-arrastech
cp Dockerfile ..
cd ..
docker build -t bd-arrastech -p 3306:3306

echo "🧹 Removendo repositório clonado..."

rm -rf  bd-arrastech

echo "✅ Ambiente configurado com sucesso!"

exit 0
