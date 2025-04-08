#!/bin/bash

# CONFIGURA ESTOS VALORES
POSTGRES_PASSWORD="miclave123"
CONTAINER_NAME="mi_postgres"
POSTGRES_VERSION="15"
PORT=5432

echo "🛠️  Actualizando sistema..."
apt update && apt upgrade -y

echo "🐳 Instalando Docker..."
apt install -y docker.io
systemctl enable docker
systemctl start docker

echo "💾 Creando volumen para persistencia..."
docker volume create pgdata

echo "🛢️ Levantando contenedor de PostgreSQL..."
docker run --name $CONTAINER_NAME \
  -e POSTGRES_PASSWORD=$POSTGRES_PASSWORD \
  -p $PORT:5432 \
  -v pgdata:/var/lib/postgresql/data \
  -d postgres:$POSTGRES_VERSION

echo "⏳ Esperando 10 segundos para inicialización de PostgreSQL..."
sleep 10

echo "🔧 Configurando PostgreSQL para permitir conexiones remotas..."

# Modificar configuración de PostgreSQL dentro del contenedor
docker exec -u postgres $CONTAINER_NAME bash -c "echo \"listen_addresses = '*'\" >> /var/lib/postgresql/data/postgresql.conf"
docker exec -u postgres $CONTAINER_NAME bash -c "echo \"host all all 0.0.0.0/0 md5\" >> /var/lib/postgresql/data/pg_hba.conf"

echo "🔄 Reiniciando contenedor para aplicar cambios..."
docker restart $CONTAINER_NAME

echo "✅ Listo. PostgreSQL está corriendo y aceptando conexiones en el puerto $PORT"
echo "📌 Usuario: postgres"
echo "📌 Contraseña: $POSTGRES_PASSWORD"
echo "📌 IP pública del servidor: $(curl -s ifconfig.me)"