# 🚀 Vagrant Lab DevOps/SRE

**Criado por:** Aleon Chagas  
**Versão:** 1.0.0  
**Especialista DevOps/SRE**

## 📋 Visão Geral

Lab completo de DevOps/SRE usando Vagrant para ambiente local. Infraestrutura virtualizada com VirtualBox, automação Ansible, Kubernetes K3s e aplicações práticas para aprendizado hands-on.

> **💻 IMPORTANTE**: Este é o lab **LOCAL** com Vagrant. Para ambiente AWS cloud, consulte `../aws-lab/`

### **🎯 Objetivos**
- ✅ **Virtualizar** infraestrutura local com Vagrant
- ✅ **Automatizar** configuração com Ansible
- ✅ **Deployar** aplicações no Kubernetes local
- ✅ **Implementar** CI/CD com Jenkins
- ✅ **Monitorar** com Prometheus/Grafana
- ✅ **Praticar** sem custos de cloud

### **🏗️ Arquitetura**
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│     Vagrant     │───▶│     Ansible     │───▶│   Kubernetes    │
│  (VirtualBox)   │    │ (Configuração)  │    │  (Aplicações)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
    VMs Locais              K3s Cluster              Weather App
   Ubuntu 20.04           Docker/kubectl           Prometheus/Grafana
```

---

## ⚡ Quick Start

### **1. Pré-requisitos**
```bash
# Instalar dependências
# VirtualBox: https://www.virtualbox.org/
# Vagrant: https://www.vagrantup.com/

# Verificar instalação
vagrant --version
vboxmanage --version
```

### **2. Deploy K3s Cluster**
```bash
# Clonar repositório
git clone <repo-url>
cd DevOps-SRE/vagrant-lab

# Deploy cluster K3s
cd labs/k3s-cluster
vagrant up

# Aguardar ~10 minutos para conclusão
```

### **3. Acessar Aplicações**
```bash
# URLs locais (após deploy)
echo "Weather App: http://10.0.0.10:30080"
echo "Grafana: http://10.0.0.10:30300 (admin/admin)"
echo "Prometheus: http://10.0.0.10:30900"
```

### **4. Limpeza**
```bash
# Destruir VMs
vagrant destroy -f
```

---

## 🛠️ Componentes

### **📁 Estrutura do Projeto**
```
vagrant-lab/
├── labs/                      # Labs individuais
│   ├── k3s-cluster/           # Kubernetes cluster
│   ├── jenkins-ci/            # CI/CD pipeline
│   ├── monitoring/            # Prometheus + Grafana
│   ├── docker-swarm/          # Container orchestration
│   ├── ansible-automation/    # Configuration management
│   └── security-stack/        # Vault + Falco
├── shared/                    # Recursos compartilhados
│   ├── scripts/               # Scripts comuns
│   ├── ansible/               # Playbooks reutilizáveis
│   └── configs/               # Configurações base
├── weather-app/               # Aplicação Weather Dashboard
│   ├── local-deploy/          # Deploy para Vagrant
│   └── k8s-manifests/         # Kubernetes YAML
└── README.md                  # Esta documentação
```

### **🔧 Labs Disponíveis**

#### **✅ Implementados**
```
✅ k3s-cluster      - Kubernetes cluster completo
✅ jenkins-ci       - CI/CD com Jenkins
✅ monitoring       - Prometheus + Grafana
✅ docker-swarm     - Docker Swarm cluster
✅ ansible-automation - Automação com Ansible
```

#### **🔄 Planejados**
```
🔄 security-stack   - Vault + Falco + OPA
🔄 logging-stack    - ELK Stack local
🔄 service-mesh     - Istio + Jaeger
🔄 gitops-lab       - ArgoCD + GitOps
🔄 chaos-engineering - Chaos Monkey
```

---

## 🚀 Labs Detalhados

### **Lab 1: K3s Cluster**
```bash
cd labs/k3s-cluster
vagrant up

# Recursos:
# - 1x Master (2GB RAM, 2 vCPU)
# - 2x Workers (1GB RAM, 1 vCPU)
# - Weather App deployada
# - Prometheus + Grafana
```

### **Lab 2: Jenkins CI/CD**
```bash
cd labs/jenkins-ci
vagrant up

# Recursos:
# - Jenkins Master
# - Build agents
# - Pipeline Weather App
# - Integration com Git
```

### **Lab 3: Monitoring Stack**
```bash
cd labs/monitoring
vagrant up

# Recursos:
# - Prometheus server
# - Grafana dashboards
# - AlertManager
# - Node exporters
```

---

## 🔧 Configurações de Rede

### **Endereços IP (Private Network)**
```
k3s-master:      10.0.0.10
k3s-worker-1:    10.0.0.11
k3s-worker-2:    10.0.0.12
jenkins:         10.0.0.20
monitoring:      10.0.0.30
ansible-control: 10.0.0.40
swarm-manager:   10.0.0.50
swarm-worker-1:  10.0.0.51
swarm-worker-2:  10.0.0.52
```

### **Portas de Acesso**
```
# Weather App
30080 - Frontend
30081 - Backend API

# Monitoring
30300 - Grafana
30900 - Prometheus

# CI/CD
8080  - Jenkins
```

---

## 🚀 Comandos Essenciais

### **Vagrant**
```bash
# Iniciar todas as VMs
vagrant up

# Status das VMs
vagrant status

# SSH na VM
vagrant ssh k3s-master

# Destruir VMs
vagrant destroy -f
```

### **Kubernetes (Local)**
```bash
# Conectar no master
vagrant ssh k3s-master

# Verificar cluster
kubectl get nodes
kubectl get pods --all-namespaces

# Deploy Weather App
kubectl apply -f /vagrant/weather-app/k8s-manifests/
```

---

## 📊 Recursos Necessários

### **Mínimo**
- **RAM**: 8GB
- **CPU**: 4 cores
- **Disk**: 20GB livre

### **Recomendado**
- **RAM**: 16GB
- **CPU**: 8 cores
- **Disk**: 50GB livre

---

## 🔄 Comparação AWS vs Local

### **AWS Lab**
- ✅ **Produção**: Ambiente real
- ❌ **Custo**: ~$60/mês otimizado

### **Vagrant Lab**
- ✅ **Gratuito**: Sem custos cloud
- ✅ **Offline**: Funciona sem internet
- ❌ **Recursos limitados**: Hardware local

---

**💡 Lab criado por Aleon Chagas - Aprenda DevOps/SRE sem custos, no seu próprio ambiente local!**