# 🔄 Shared Resources

## 📋 Visão Geral

Recursos compartilhados entre os labs AWS e Vagrant para reutilização e consistência.

## 📁 Estrutura

```
shared-resources/
├── weather-app/          # Aplicação base Weather Dashboard
│   ├── backend/             # Node.js API
│   ├── frontend/            # React SPA
│   ├── k8s-manifests/       # Kubernetes YAML
│   └── docker-compose.yml   # Compose para desenvolvimento
├── ansible-roles/        # Roles Ansible reutilizáveis
│   ├── k3s-cluster/         # Setup cluster K3s
│   ├── monitoring/          # Prometheus + Grafana
│   └── security/            # Configurações de segurança
└── scripts/             # Scripts comuns
    ├── health-check.sh      # Verificação de saúde
    ├── backup.sh            # Backup de dados
    └── cleanup.sh           # Limpeza de recursos
```

## 🌤️ Weather App

### **Componentes**
- **Frontend**: React SPA com geolocalização
- **Backend**: Node.js API com métricas Prometheus
- **Cache**: Redis para performance
- **APIs**: OpenWeatherMap + IP-API

### **Deployments Suportados**
- ✅ **AWS**: Kubernetes K3s na nuvem
- ✅ **Vagrant**: Kubernetes K3s local
- ✅ **Docker**: Compose para desenvolvimento

### **Uso**
```bash
# Desenvolvimento local
cd weather-app && docker-compose up

# Deploy AWS
# Usar manifests em ../aws-lab/weather-app/

# Deploy Vagrant
# Usar manifests em ../vagrant-lab/weather-app/
```

## 🔧 Ansible Roles

### **k3s-cluster**
Role para setup completo de cluster K3s.

### **monitoring**
Role para deploy de Prometheus + Grafana.

### **security**
Role para configurações de segurança básicas.

## 📜 Scripts Comuns

### **health-check.sh**
Verificação de saúde dos serviços.

### **backup.sh**
Backup de dados importantes.

### **cleanup.sh**
Limpeza de recursos temporários.

---

**💡 Recursos compartilhados para maximizar reutilização entre labs!**