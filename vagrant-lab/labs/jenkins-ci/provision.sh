#!/bin/bash
# Script de provisionamento do Jenkins CI/CD Lab
# Criado por: Aleon Chagas
# Objetivo: Instalar e configurar Jenkins com ferramentas DevOps

set -euo pipefail

echo "🚀 Iniciando provisionamento do Jenkins CI/CD Lab..."

# ============================================================================
# INSTALAÇÃO DE DEPENDÊNCIAS BÁSICAS
# ============================================================================
echo "📦 Instalando dependências básicas..."
yum install epel-release -y
yum install wget git -y

# ============================================================================
# INSTALAÇÃO DO JENKINS
# ============================================================================
echo "🔧 Configurando repositório e instalando Jenkins..."

# Adicionar repositório oficial do Jenkins
sudo wget --no-check-certificate -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key

# Instalar Java 11 (requisito do Jenkins)
echo "☕ Instalando Java 11..."
yum install java-11-openjdk-devel -y

# Instalar Jenkins
echo "🏗️ Instalando Jenkins..."
yum install jenkins -y

# Iniciar serviço Jenkins
echo "▶️ Iniciando serviço Jenkins..."
systemctl daemon-reload
systemctl enable jenkins
service jenkins start

echo "✅ Jenkins instalado e iniciado com sucesso!"

# ============================================================================
# INSTALAÇÃO DO DOCKER E DOCKER COMPOSE
# ============================================================================
echo "🐳 Instalando Docker e Docker Compose..."

# Instalar utilitários do YUM
sudo yum install -y yum-utils

# Adicionar repositório oficial do Docker
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Instalar Docker CE
sudo yum install docker-ce docker-ce-cli containerd.io -y

# Iniciar e habilitar Docker
sudo systemctl start docker
sudo systemctl enable docker

# Instalar Docker Compose
echo "📦 Instalando Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# Reiniciar Docker para aplicar configurações
systemctl daemon-reload
systemctl restart docker

# Adicionar usuário jenkins ao grupo docker (para executar comandos Docker)
echo "👥 Adicionando usuário jenkins ao grupo docker..."
usermod -aG docker jenkins

echo "✅ Docker e Docker Compose instalados com sucesso!"

# ============================================================================
# INSTALAÇÃO DO SONARQUBE SCANNER
# ============================================================================
echo "🔍 Instalando SonarQube Scanner..."

# Instalar dependências para download
yum install wget unzip -y

# Baixar SonarQube Scanner
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.6.2.2472-linux.zip

# Extrair e mover para diretório padrão
unzip sonar-scanner-cli-4.6.2.2472-linux.zip -d /opt/
mv /opt/sonar-scanner-4.6.2.2472-linux /opt/sonar-scanner

# Configurar permissões
chown -R jenkins:jenkins /opt/sonar-scanner

# Adicionar ao PATH do sistema
echo 'export PATH=$PATH:/opt/sonar-scanner/bin' | sudo tee -a /etc/profile

echo "✅ SonarQube Scanner instalado com sucesso!"

# ============================================================================
# INSTALAÇÃO DO NODE.JS
# ============================================================================
echo "🟢 Instalando Node.js 10.x..."

# Adicionar repositório NodeSource
curl -sL https://rpm.nodesource.com/setup_10.x | sudo bash -

# Instalar Node.js
sudo yum install nodejs -y

echo "✅ Node.js instalado com sucesso!"

# ============================================================================
# VERIFICAÇÕES FINAIS
# ============================================================================
echo "🔍 Verificando instalações..."

# Verificar versões instaladas
echo "📋 Versões instaladas:"
echo "Java: $(java -version 2>&1 | head -1)"
echo "Jenkins: Instalado (verificar em http://10.0.0.20:8080)"
echo "Docker: $(docker --version)"
echo "Docker Compose: $(docker-compose --version)"
echo "Node.js: $(node --version)"
echo "NPM: $(npm --version)"

# Verificar status dos serviços
echo "🔧 Status dos serviços:"
systemctl is-active jenkins && echo "✅ Jenkins: Ativo" || echo "❌ Jenkins: Inativo"
systemctl is-active docker && echo "✅ Docker: Ativo" || echo "❌ Docker: Inativo"

echo ""
echo "🎉 Provisionamento do Jenkins CI/CD Lab concluído!"
echo "💡 Lab criado por Aleon Chagas - DevOps/SRE Expert"