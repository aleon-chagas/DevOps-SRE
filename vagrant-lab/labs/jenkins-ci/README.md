# 🚀 Lab Jenkins CI/CD - Pipeline Automatizado

**Criado por:** Aleon Chagas  
**Objetivo:** Implementar pipelines CI/CD completos para práticas DevOps

## 📋 Visão Geral

Este lab implementa um ambiente Jenkins completo para aprendizado de CI/CD, integração contínua e deploy automatizado. Inclui ferramentas essenciais como Docker, SonarQube Scanner e Node.js.

### **🎯 Objetivos de Aprendizado**
- ✅ **Configurar** servidor Jenkins local
- ✅ **Criar** pipelines CI/CD automatizados
- ✅ **Integrar** análise de código com SonarQube
- ✅ **Implementar** build e deploy com Docker
- ✅ **Praticar** conceitos de DevOps e automação

## 🏗️ Arquitetura do Lab

```
┌─────────────────────────────────────────────────────────────┐
│                    Jenkins CI/CD Server                      │
├─────────────────────────────────────────────────────────────┤
│  IP: 10.0.0.20                                              │
│  RAM: 2GB | CPU: 2 vCPU                                     │
│                                                             │
│  🛠️ Ferramentas Instaladas:                                │
│  • Jenkins (Java 11)                                        │
│  • Docker + Docker Compose                                  │
│  • SonarQube Scanner                                        │
│  • Node.js 10.x                                             │
│  • Git                                                       │
└─────────────────────────────────────────────────────────────┘
```

## 📋 Pré-requisitos

### **Software Necessário**
```bash
# Verificar instalações
vagrant --version    # >= 2.2.0
vboxmanage --version # >= 6.0.0

# Recursos mínimos do sistema
# RAM: 4GB (8GB recomendado)
# CPU: 2 cores (4 cores recomendado)
# Disk: 5GB livre
```

## 🚀 Guia Passo-a-Passo

### **Passo 1: Preparação do Ambiente**
```bash
# 1. Navegar para o diretório do lab
cd /home/ubuntu/SRE/personal/aleon-chagas/DevOps-SRE/vagrant-lab/labs/jenkins-ci

# 2. Verificar arquivos do lab
ls -la
# Deve mostrar: Vagrantfile, README.md, provision.sh

# 3. Verificar conteúdo do Vagrantfile
cat Vagrantfile
```

### **Passo 2: Provisionar o Servidor Jenkins**
```bash
# 1. Iniciar a VM (aguardar ~10-15 minutos)
vagrant up

# 2. Acompanhar o processo de instalação
vagrant ssh jenkins -c "sudo tail -f /var/log/jenkins/jenkins.log"

# 3. Verificar status dos serviços
vagrant ssh jenkins -c "sudo systemctl status jenkins"
vagrant ssh jenkins -c "sudo systemctl status docker"
```

### **Passo 3: Configurar Jenkins Inicial**
```bash
# 1. Obter senha inicial do Jenkins
vagrant ssh jenkins -c "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"

# 2. Acessar Jenkins no navegador
# URL: http://10.0.0.20:8080

# 3. Seguir wizard de configuração inicial:
# - Inserir senha inicial
# - Instalar plugins sugeridos
# - Criar usuário admin
```

### **Passo 4: Instalar Plugins Essenciais**
```bash
# No Jenkins Web UI:
# Manage Jenkins > Manage Plugins > Available

# Plugins recomendados para DevOps:
# - Docker Pipeline
# - SonarQube Scanner
# - Git Parameter
# - Build Pipeline
# - Blue Ocean
# - Prometheus Metrics
```

### **Passo 5: Configurar Ferramentas**
```bash
# 1. Configurar Docker
# Manage Jenkins > Global Tool Configuration
# Docker > Add Docker
# Name: docker
# Install automatically: Docker latest

# 2. Configurar SonarQube Scanner
# SonarQube Scanner > Add SonarQube Scanner
# Name: sonar-scanner
# Install automatically: Latest version

# 3. Configurar Node.js
# NodeJS > Add NodeJS
# Name: nodejs-10
# Version: NodeJS 10.x
```

### **Passo 6: Criar Pipeline de Exemplo**
```bash
# 1. No Jenkins: New Item > Pipeline
# Nome: weather-app-pipeline

# 2. Pipeline Script (exemplo):
pipeline {
    agent any
    
    tools {
        nodejs 'nodejs-10'
    }
    
    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/seu-usuario/weather-app.git'
            }
        }
        
        stage('Install Dependencies') {
            steps {
                sh 'npm install'
            }
        }
        
        stage('Test') {
            steps {
                sh 'npm test'
            }
        }
        
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh 'sonar-scanner'
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("weather-app:${env.BUILD_NUMBER}")
                }
            }
        }
        
        stage('Deploy') {
            steps {
                sh 'docker run -d -p 3000:3000 weather-app:${BUILD_NUMBER}'
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
    }
}
```

## 🔗 URLs de Acesso

### **Jenkins**
- **URL**: http://10.0.0.20:8080
- **Usuário**: admin (configurado no wizard)
- **Senha**: definida durante configuração inicial

### **Aplicações Deployadas**
- **Weather App** (se deployada): http://10.0.0.20:3000
- **Outras apps**: Portas dinâmicas conforme pipeline

## 📊 Comandos Úteis para DevOps

### **Gerenciamento Jenkins**
```bash
# Conectar na VM
vagrant ssh jenkins

# Status dos serviços
sudo systemctl status jenkins
sudo systemctl status docker

# Logs do Jenkins
sudo tail -f /var/log/jenkins/jenkins.log

# Reiniciar Jenkins
sudo systemctl restart jenkins

# Verificar jobs em execução
sudo docker ps
```

### **Docker Operations**
```bash
# Listar imagens
sudo docker images

# Listar containers
sudo docker ps -a

# Limpar recursos não utilizados
sudo docker system prune -f

# Verificar logs de container
sudo docker logs <container-id>
```

### **Monitoramento de Recursos**
```bash
# Uso de CPU e memória
top
htop

# Espaço em disco
df -h

# Processos Jenkins
ps aux | grep jenkins
```

## 🐛 Troubleshooting

### **Jenkins não inicia**
```bash
# Verificar logs de erro
vagrant ssh jenkins -c "sudo journalctl -u jenkins -f"

# Verificar porta em uso
vagrant ssh jenkins -c "sudo netstat -tlnp | grep 8080"

# Verificar espaço em disco
vagrant ssh jenkins -c "df -h"

# Reiniciar serviço
vagrant ssh jenkins -c "sudo systemctl restart jenkins"
```

### **Docker com problemas**
```bash
# Status do Docker
vagrant ssh jenkins -c "sudo systemctl status docker"

# Verificar permissões do usuário jenkins
vagrant ssh jenkins -c "sudo usermod -aG docker jenkins"
vagrant ssh jenkins -c "sudo systemctl restart jenkins"

# Testar Docker
vagrant ssh jenkins -c "sudo docker run hello-world"
```

### **Pipeline falha**
```bash
# Verificar logs do build no Jenkins UI
# Console Output do job específico

# Verificar ferramentas instaladas
vagrant ssh jenkins -c "which node"
vagrant ssh jenkins -c "which sonar-scanner"
vagrant ssh jenkins -c "which docker"

# Verificar variáveis de ambiente
vagrant ssh jenkins -c "echo \$PATH"
```

## 🧹 Limpeza do Ambiente

### **Limpeza Completa**
```bash
# Destruir VM
vagrant destroy -f

# Verificar limpeza
vagrant status
vboxmanage list vms | grep jenkins
```

### **Limpeza Parcial**
```bash
# Parar Jenkins sem destruir VM
vagrant ssh jenkins -c "sudo systemctl stop jenkins"

# Limpar workspace Jenkins
vagrant ssh jenkins -c "sudo rm -rf /var/lib/jenkins/workspace/*"

# Limpar containers Docker
vagrant ssh jenkins -c "sudo docker system prune -af"
```

## 📚 Conceitos DevOps Aplicados

### **Continuous Integration**
- **Automação**: Builds automáticos a cada commit
- **Testes**: Execução automática de testes unitários
- **Qualidade**: Análise de código com SonarQube

### **Continuous Deployment**
- **Containerização**: Build de imagens Docker
- **Deploy**: Automatização de deploy em ambientes
- **Rollback**: Capacidade de reverter deploys

### **Infrastructure as Code**
- **Vagrantfile**: Define infraestrutura como código
- **Pipeline as Code**: Jenkinsfile versionado
- **Reprodutibilidade**: Ambiente consistente

## 🚀 Próximos Passos

### **Integrações Avançadas**
- Conectar com cluster K3s para deploy
- Integrar com SonarQube externo
- Configurar notificações Slack/Email
- Implementar Blue-Green deployment

### **Segurança**
- Configurar HTTPS no Jenkins
- Implementar autenticação LDAP/SSO
- Escanear vulnerabilidades em containers
- Configurar secrets management

---

**💡 Lab criado por Aleon Chagas - Domine CI/CD e automação DevOps!**