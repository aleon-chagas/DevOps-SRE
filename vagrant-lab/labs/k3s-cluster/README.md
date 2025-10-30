# 🚀 Lab K3s Cluster - Kubernetes Local

**Criado por:** Aleon Chagas  
**Objetivo:** Implementar cluster Kubernetes local para aprendizado DevOps/SRE

## 📋 Visão Geral

Este lab cria um cluster Kubernetes completo usando K3s (Kubernetes leve) em ambiente local com Vagrant. Ideal para aprender conceitos de orquestração de containers, deployments e monitoramento.

### **🎯 Objetivos de Aprendizado**
- ✅ **Provisionar** cluster K3s multi-node
- ✅ **Deployar** aplicação Weather Dashboard
- ✅ **Configurar** monitoramento com Prometheus/Grafana
- ✅ **Praticar** comandos kubectl essenciais
- ✅ **Implementar** conceitos de SRE (observabilidade, reliability)

## 🏗️ Arquitetura do Lab

```
┌─────────────────────────────────────────────────────────────┐
│                    K3s Cluster Local                       │
├─────────────────┬─────────────────┬─────────────────────────┤
│   k3s-master    │  k3s-worker-1   │     k3s-worker-2        │
│   10.0.0.10     │   10.0.0.11     │      10.0.0.12          │
│   2GB RAM       │   1GB RAM       │      1GB RAM            │
│   2 vCPU        │   1 vCPU        │      1 vCPU             │
└─────────────────┴─────────────────┴─────────────────────────┘
```

## 📋 Pré-requisitos

### **Software Necessário**
```bash
# Verificar instalações
vagrant --version    # >= 2.2.0
vboxmanage --version # >= 6.0.0

# Recursos mínimos do sistema
# RAM: 8GB (16GB recomendado)
# CPU: 4 cores (8 cores recomendado) 
# Disk: 10GB livre
```

## 🚀 Guia Passo-a-Passo

### **Passo 1: Preparação do Ambiente**
```bash
# 1. Navegar para o diretório do lab
cd /home/ubuntu/SRE/personal/aleon-chagas/DevOps-SRE/vagrant-lab/labs/k3s-cluster

# 2. Verificar arquivos do lab
ls -la
# Deve mostrar: Vagrantfile, README.md, redis.yaml, redis-app.yaml

# 3. Verificar status inicial
vagrant status
```

### **Passo 2: Provisionar o Cluster**
```bash
# 1. Iniciar todas as VMs (aguardar ~10-15 minutos)
vagrant up

# 2. Verificar status das VMs
vagrant status
# Todas devem estar "running"

# 3. Verificar conectividade
vagrant ssh k3s-master -c "ping -c 2 10.0.0.11"
vagrant ssh k3s-master -c "ping -c 2 10.0.0.12"
```

### **Passo 3: Verificar o Cluster K3s**
```bash
# 1. Conectar no master
vagrant ssh k3s-master

# 2. Verificar nodes do cluster
kubectl get nodes -o wide
# Deve mostrar 3 nodes (1 master + 2 workers) em estado "Ready"

# 3. Verificar componentes do sistema
kubectl get pods -n kube-system

# 4. Verificar namespaces
kubectl get namespaces
```

### **Passo 4: Deploy da Aplicação Weather**
```bash
# 1. Ainda conectado no master, aplicar manifests
kubectl apply -f /vagrant/redis.yaml
kubectl apply -f /vagrant/redis-app.yaml

# 2. Verificar deployments
kubectl get deployments -A

# 3. Verificar pods
kubectl get pods -A -o wide

# 4. Verificar services
kubectl get services -A
```

### **Passo 5: Configurar Monitoramento**
```bash
# 1. Instalar Prometheus stack via Helm
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# 2. Instalar monitoring stack
helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace \
  --set grafana.service.type=NodePort \
  --set grafana.service.nodePort=30300 \
  --set prometheus.service.type=NodePort \
  --set prometheus.service.nodePort=30900

# 3. Verificar pods de monitoramento
kubectl get pods -n monitoring
```

### **Passo 6: Acessar as Aplicações**
```bash
# 1. Sair da VM (Ctrl+D ou exit)
exit

# 2. Testar conectividade das aplicações
curl -I http://10.0.0.10:30080  # Weather App
curl -I http://10.0.0.10:30300  # Grafana
curl -I http://10.0.0.10:30900  # Prometheus
```

## 🔗 URLs de Acesso

### **Aplicações Principais**
- **Weather App**: http://10.0.0.10:30080
  - Frontend React com geolocalização
  - API REST com métricas

### **Monitoramento**
- **Grafana**: http://10.0.0.10:30300
  - **Usuário**: admin
  - **Senha**: prom-operator (padrão Helm)
- **Prometheus**: http://10.0.0.10:30900
  - Interface de consulta de métricas

## 📊 Comandos Úteis para SRE

### **Observabilidade**
```bash
# Conectar no master
vagrant ssh k3s-master

# Verificar saúde do cluster
kubectl get componentstatuses
kubectl top nodes
kubectl top pods -A

# Logs de aplicações
kubectl logs -f deployment/redis-app -n default
kubectl logs -f deployment/weather-frontend -n weather-app

# Eventos do cluster
kubectl get events --sort-by=.metadata.creationTimestamp

# Descrever recursos para troubleshooting
kubectl describe node k3s-master
kubectl describe pod <pod-name> -n <namespace>
```

### **Reliability Testing**
```bash
# Simular falha de pod
kubectl delete pod -l app=redis-app --force --grace-period=0

# Verificar recuperação automática
kubectl get pods -w

# Escalar aplicação
kubectl scale deployment redis-app --replicas=3

# Verificar distribuição nos nodes
kubectl get pods -o wide
```

## 🐛 Troubleshooting

### **VMs não iniciam**
```bash
# Verificar VirtualBox
vboxmanage list vms
vboxmanage list runningvms

# Verificar recursos do sistema
free -h  # RAM disponível
df -h    # Espaço em disco

# Reiniciar VMs problemáticas
vagrant halt k3s-worker-1
vagrant up k3s-worker-1
```

### **Cluster K3s com problemas**
```bash
# Verificar status do K3s no master
vagrant ssh k3s-master -c "sudo systemctl status k3s"

# Verificar logs do K3s
vagrant ssh k3s-master -c "sudo journalctl -u k3s -f"

# Reiniciar K3s se necessário
vagrant ssh k3s-master -c "sudo systemctl restart k3s"

# Verificar workers
vagrant ssh k3s-worker-1 -c "sudo systemctl status k3s-agent"
vagrant ssh k3s-worker-2 -c "sudo systemctl status k3s-agent"
```

### **Aplicações não respondem**
```bash
# Verificar pods
kubectl get pods -A

# Verificar services
kubectl get svc -A

# Verificar endpoints
kubectl get endpoints -A

# Testar conectividade interna
kubectl run test-pod --image=busybox --rm -it -- /bin/sh
# Dentro do pod: wget -qO- http://service-name:port
```

## 🧹 Limpeza do Ambiente

### **Limpeza Completa**
```bash
# Destruir todas as VMs
vagrant destroy -f

# Verificar limpeza
vagrant status
vboxmanage list vms | grep k3s
```

### **Limpeza Parcial**
```bash
# Parar VMs sem destruir
vagrant halt

# Reiniciar cluster
vagrant up
```

## 📚 Conceitos SRE Aplicados

### **Observabilidade**
- **Métricas**: Prometheus coleta métricas do cluster e aplicações
- **Logs**: Centralizados via kubectl e journalctl
- **Traces**: Preparado para implementação futura

### **Reliability**
- **Self-healing**: Kubernetes reinicia pods automaticamente
- **Redundância**: Multi-node cluster com distribuição de carga
- **Health checks**: Liveness e readiness probes

### **Automation**
- **Infrastructure as Code**: Vagrantfile define infraestrutura
- **Declarative config**: Manifests YAML para aplicações
- **GitOps ready**: Preparado para ArgoCD futuro

---

**💡 Lab criado por Aleon Chagas - Aprenda Kubernetes e SRE na prática!**