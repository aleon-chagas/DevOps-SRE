# 🚀 Lab Monitoring Stack - Observabilidade Completa

**Criado por:** Aleon Chagas  
**Objetivo:** Implementar stack completo de monitoramento para práticas SRE

## 📋 Visão Geral

Este lab implementa uma stack completa de monitoramento usando Prometheus e Grafana via Docker. Ideal para aprender conceitos de observabilidade, métricas, alertas e dashboards para SRE.

### **🎯 Objetivos de Aprendizado**
- ✅ **Configurar** Prometheus para coleta de métricas
- ✅ **Implementar** Grafana para visualização
- ✅ **Criar** dashboards personalizados
- ✅ **Configurar** alertas e notificações
- ✅ **Praticar** conceitos de SRE e observabilidade

## 🏗️ Arquitetura do Lab

```
┌─────────────────────────────────────────────────────────────┐
│                   Monitoring Server                         │
├─────────────────────────────────────────────────────────────┤
│  IP: 10.0.0.30                                              │
│  RAM: 2GB | CPU: 2 vCPU                                     │
│                                                             │
│  📊 Stack de Monitoramento:                               │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │  Prometheus (9090) - Métricas                          │ │
│  │  Grafana (3000) - Dashboards                        │ │
│  │  Node Exporter (9100) - Métricas do sistema          │ │
│  │  AlertManager (9093) - Alertas                      │ │
│  └─────────────────────────────────────────────────────────┘ │
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
cd /home/ubuntu/SRE/personal/aleon-chagas/DevOps-SRE/vagrant-lab/labs/monitoring

# 2. Verificar arquivos do lab
ls -la
# Deve mostrar: Vagrantfile, README.md, provision.sh, prometheus.yml

# 3. Verificar configuração do Prometheus
cat prometheus.yml
```

### **Passo 2: Provisionar o Servidor de Monitoramento**
```bash
# 1. Iniciar a VM (aguardar ~5-10 minutos)
vagrant up

# 2. Verificar status da VM
vagrant status

# 3. Verificar serviços Docker
vagrant ssh monitoring -c "sudo docker ps"
```

### **Passo 3: Configurar Stack de Monitoramento**
```bash
# 1. Conectar na VM
vagrant ssh monitoring

# 2. Criar estrutura de diretórios
sudo mkdir -p /opt/monitoring/{prometheus,grafana,alertmanager}
sudo chown -R vagrant:vagrant /opt/monitoring

# 3. Criar docker-compose.yml
cat > /opt/monitoring/docker-compose.yml << 'EOF'
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--storage.tsdb.retention.time=200h'
      - '--web.enable-lifecycle'
    restart: unless-stopped

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3000:3000"
    volumes:
      - grafana_data:/var/lib/grafana
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_USERS_ALLOW_SIGN_UP=false
    restart: unless-stopped

  node-exporter:
    image: prom/node-exporter:latest
    container_name: node-exporter
    ports:
      - "9100:9100"
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.rootfs=/rootfs'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)'
    restart: unless-stopped

  alertmanager:
    image: prom/alertmanager:latest
    container_name: alertmanager
    ports:
      - "9093:9093"
    volumes:
      - ./alertmanager/alertmanager.yml:/etc/alertmanager/alertmanager.yml
    restart: unless-stopped

volumes:
  prometheus_data:
  grafana_data:
EOF

# 4. Criar configuração do Prometheus
mkdir -p /opt/monitoring/prometheus
cat > /opt/monitoring/prometheus/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']

  - job_name: 'grafana'
    static_configs:
      - targets: ['grafana:3000']
EOF

# 5. Criar configuração do AlertManager
mkdir -p /opt/monitoring/alertmanager
cat > /opt/monitoring/alertmanager/alertmanager.yml << 'EOF'
global:
  smtp_smarthost: 'localhost:587'
  smtp_from: 'alertmanager@example.org'

route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'web.hook'

receivers:
  - name: 'web.hook'
    webhook_configs:
      - url: 'http://127.0.0.1:5001/'
EOF
```

### **Passo 4: Iniciar Stack de Monitoramento**
```bash
# 1. Ainda conectado na VM, iniciar serviços
cd /opt/monitoring
sudo docker-compose up -d

# 2. Verificar containers em execução
sudo docker-compose ps

# 3. Verificar logs
sudo docker-compose logs -f prometheus
sudo docker-compose logs -f grafana
```

### **Passo 5: Configurar Grafana**
```bash
# 1. Sair da VM (Ctrl+D ou exit)
exit

# 2. Acessar Grafana no navegador
# URL: http://10.0.0.30:3000
# Usuário: admin
# Senha: admin

# 3. Adicionar Prometheus como Data Source:
# Configuration > Data Sources > Add data source
# Type: Prometheus
# URL: http://prometheus:9090
# Save & Test
```

### **Passo 6: Importar Dashboards**
```bash
# No Grafana Web UI:
# + > Import

# Dashboards recomendados (IDs):
# 1860 - Node Exporter Full
# 3662 - Prometheus 2.0 Overview
# 7249 - Kubernetes Cluster Monitoring
# 11074 - Node Exporter for Prometheus Dashboard
```

## 🔗 URLs de Acesso

### **Monitoramento**
- **Grafana**: http://10.0.0.30:3000
  - **Usuário**: admin
  - **Senha**: admin
- **Prometheus**: http://10.0.0.30:9090
  - Interface de consulta PromQL
- **AlertManager**: http://10.0.0.30:9093
  - Gerenciamento de alertas

### **Métricas**
- **Node Exporter**: http://10.0.0.30:9100/metrics
  - Métricas do sistema operacional

## 📊 Consultas PromQL Úteis

### **Métricas de Sistema**
```promql
# Uso de CPU
100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Uso de memória
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100

# Uso de disco
100 - ((node_filesystem_avail_bytes * 100) / node_filesystem_size_bytes)

# Load average
node_load1
node_load5
node_load15

# Network I/O
irate(node_network_receive_bytes_total[5m])
irate(node_network_transmit_bytes_total[5m])
```

### **Métricas de Aplicação**
```promql
# Requests por segundo
rate(http_requests_total[5m])

# Latência média
rate(http_request_duration_seconds_sum[5m]) / rate(http_request_duration_seconds_count[5m])

# Taxa de erro
rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m])
```

## 🐛 Troubleshooting

### **Containers não iniciam**
```bash
# Verificar logs dos containers
vagrant ssh monitoring -c "cd /opt/monitoring && sudo docker-compose logs prometheus"
vagrant ssh monitoring -c "cd /opt/monitoring && sudo docker-compose logs grafana"

# Verificar portas em uso
vagrant ssh monitoring -c "sudo netstat -tlnp | grep -E '(3000|9090|9100|9093)'"

# Reiniciar stack
vagrant ssh monitoring -c "cd /opt/monitoring && sudo docker-compose restart"
```

### **Grafana não conecta no Prometheus**
```bash
# Verificar conectividade entre containers
vagrant ssh monitoring -c "sudo docker exec grafana ping prometheus"

# Verificar configuração do Prometheus
vagrant ssh monitoring -c "sudo docker exec prometheus cat /etc/prometheus/prometheus.yml"

# Testar endpoint do Prometheus
vagrant ssh monitoring -c "curl http://10.0.0.30:9090/api/v1/query?query=up"
```

### **Métricas não aparecem**
```bash
# Verificar targets no Prometheus
# Acessar: http://10.0.0.30:9090/targets

# Verificar configuração do Node Exporter
vagrant ssh monitoring -c "curl http://10.0.0.30:9100/metrics | head -20"

# Recarregar configuração do Prometheus
vagrant ssh monitoring -c "sudo docker exec prometheus kill -HUP 1"
```

## 🧹 Limpeza do Ambiente

### **Limpeza Completa**
```bash
# Parar e remover containers
vagrant ssh monitoring -c "cd /opt/monitoring && sudo docker-compose down -v"

# Destruir VM
vagrant destroy -f

# Verificar limpeza
vagrant status
vboxmanage list vms | grep monitoring
```

### **Limpeza Parcial**
```bash
# Parar apenas os containers
vagrant ssh monitoring -c "cd /opt/monitoring && sudo docker-compose stop"

# Reiniciar stack
vagrant ssh monitoring -c "cd /opt/monitoring && sudo docker-compose start"

# Limpar dados (cuidado!)
vagrant ssh monitoring -c "cd /opt/monitoring && sudo docker-compose down -v"
vagrant ssh monitoring -c "cd /opt/monitoring && sudo docker-compose up -d"
```

## 📚 Conceitos SRE Aplicados

### **Observabilidade (3 Pilares)**
- **Métricas**: Prometheus coleta e armazena métricas
- **Logs**: Preparado para integração com ELK Stack
- **Traces**: Base para implementação futura com Jaeger

### **SLIs/SLOs**
- **Latency**: Tempo de resposta das aplicações
- **Availability**: Uptime dos serviços
- **Error Rate**: Taxa de erros HTTP
- **Throughput**: Requests por segundo

### **Alerting**
- **Proativo**: Alertas antes que usuários sejam impactados
- **Actionable**: Alertas que requerem ação humana
- **Escalation**: Escalonamento automático de alertas

## 🚀 Próximos Passos

### **Integrações Avançadas**
- Conectar com cluster K3s para métricas Kubernetes
- Integrar com Jenkins para métricas de CI/CD
- Configurar alertas via Slack/Email
- Implementar dashboards customizados

### **Segurança e Performance**
- Configurar HTTPS no Grafana
- Implementar autenticação externa (LDAP/OAuth)
- Otimizar retenção de métricas
- Configurar backup de dashboards

---

**💡 Lab criado por Aleon Chagas - Domine observabilidade e monitoramento SRE!**