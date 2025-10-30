#!/bin/bash
# Script de provisionamento do Monitoring Stack Lab
# Criado por: Aleon Chagas
# Objetivo: Instalar Docker para stack de monitoramento (Prometheus + Grafana)

set -euo pipefail

echo "📊 Iniciando provisionamento do Monitoring Stack Lab..."

# ============================================================================
# INSTALAÇÃO DO DOCKER
# ============================================================================
echo "🐳 Instalando Docker para stack de monitoramento..."

# Instalar utilitários do YUM
echo "📦 Instalando dependências..."
sudo yum install -y yum-utils

# Adicionar repositório oficial do Docker
echo "📋 Adicionando repositório Docker..."
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Instalar Docker CE e componentes
echo "⬇️ Instalando Docker CE..."
sudo yum install docker-ce docker-ce-cli containerd.io -y

# Iniciar e habilitar Docker
echo "▶️ Iniciando serviço Docker..."
sudo systemctl start docker
sudo systemctl enable docker

# ============================================================================
# CONFIGURAÇÕES ADICIONAIS
# ============================================================================
echo "⚙️ Configurando Docker..."

# Adicionar usuário vagrant ao grupo docker
sudo usermod -aG docker vagrant

# Instalar Docker Compose
echo "📦 Instalando Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

# ============================================================================
# VERIFICAÇÕES FINAIS
# ============================================================================
echo "🔍 Verificando instalação..."

# Verificar versões instaladas
echo "📋 Versões instaladas:"
echo "Docker: $(docker --version)"
echo "Docker Compose: $(docker-compose --version)"

# Verificar status do serviço
echo "🔧 Status do Docker:"
systemctl is-active docker && echo "✅ Docker: Ativo" || echo "❌ Docker: Inativo"

# Testar Docker
echo "🧪 Testando Docker..."
sudo docker run --rm hello-world > /dev/null 2>&1 && echo "✅ Docker funcionando corretamente" || echo "❌ Erro no teste do Docker"

echo ""
echo "🎉 Provisionamento do Monitoring Stack Lab concluído!"
echo "💡 Lab criado por Aleon Chagas - DevOps/SRE Expert"