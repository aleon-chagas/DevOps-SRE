# 🚀 Lab DevOps/SRE - Ferramentas de Mercado

## 🏗️ Arquitetura Proposta

```
┌─────────────────────────────────────────────────────────────────┐
│                        AWS VPC                                  │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │   Jenkins       │  │  K8s Master     │  │   Monitoring    │  │
│  │   - CI/CD       │  │  - Control      │  │   - Prometheus  │  │
│  │   - Pipelines   │  │  - API Server   │  │   - Grafana     │  │
│  │   - Agents      │  │  - etcd         │  │   - AlertMgr    │  │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘  │
│                                                                 │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │  K8s Worker 1   │  │  K8s Worker 2   │  │   Logging       │  │
│  │  - ArgoCD       │  │  - Apps         │  │   - ELK Stack   │  │
│  │  - GitOps       │  │  - Workloads    │  │   - Graylog     │  │
│  │  - Deployments  │  │  - Services     │  │   - Fluentd     │  │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## 🛠️ Stack de Ferramentas

### **CI/CD & GitOps**
- **Jenkins** - Pipeline automation
- **ArgoCD** - GitOps deployment
- **Harbor** - Container registry
- **SonarQube** - Code quality

### **Kubernetes & Orchestration**
- **K3s** - Lightweight Kubernetes
- **Helm** - Package manager
- **Ingress NGINX** - Load balancer
- **Cert-Manager** - SSL certificates

### **Monitoring & Observability**
- **Prometheus** - Metrics collection
- **Grafana** - Visualization
- **AlertManager** - Alerting
- **Jaeger** - Distributed tracing

### **Logging & Security**
- **ELK Stack** (Elasticsearch, Logstash, Kibana)
- **Graylog** - Log management
- **Falco** - Runtime security
- **OPA Gatekeeper** - Policy enforcement

### **Infrastructure & Automation**
- **Terraform** - Infrastructure as Code
- **Ansible** - Configuration management
- **Vault** - Secrets management
- **Consul** - Service discovery

---

## 🎯 Cenários de Uso

### **1. Pipeline Completo**
```
Developer Push → GitHub → Jenkins → Build → Test → SonarQube →
Harbor Registry → ArgoCD → K8s Deploy → Monitoring
```

### **2. Observabilidade 360°**
- **Metrics**: Prometheus + Grafana
- **Logs**: ELK + Graylog
- **Traces**: Jaeger
- **Alerts**: AlertManager + PagerDuty

### **3. Security & Compliance**
- **Runtime**: Falco monitoring
- **Policies**: OPA Gatekeeper
- **Secrets**: Vault integration
- **Scanning**: Trivy + Clair

---

## 📋 Configuração das Instâncias

### **Instance 1: Jenkins + Tools**
```yaml
Name: devops-jenkins
Type: t3.medium (2 vCPU, 4GB RAM)
Storage: 50GB
Services:
  - Jenkins Master
  - SonarQube
  - Harbor Registry
  - Vault
```

### **Instance 2: K8s Master**
```yaml
Name: k8s-master
Type: t3.medium (2 vCPU, 4GB RAM)
Storage: 30GB
Services:
  - K3s Server
  - ArgoCD
  - Prometheus
  - Grafana
```

### **Instance 3: K8s Worker 1**
```yaml
Name: k8s-worker-1
Type: t3.medium (2 vCPU, 4GB RAM)
Storage: 30GB
Services:
  - K3s Agent
  - Application Workloads
  - Ingress Controller
```

### **Instance 4: Monitoring & Logging**
```yaml
Name: monitoring-logging
Type: t3.large (2 vCPU, 8GB RAM)
Storage: 100GB
Services:
  - Elasticsearch
  - Kibana
  - Graylog
  - Jaeger
```

---

## 🚀 Implementação

### **Fase 1: Infraestrutura Base**
```bash
# 1. Provisionar EC2 instances
terraform apply -var-file="environments/devops-lab.tfvars"

# 2. Configurar base system
ansible-playbook playbooks/base-system.yml

# 3. Instalar Docker + K3s
ansible-playbook playbooks/k8s-cluster.yml
```

### **Fase 2: CI/CD Stack**
```bash
# 1. Deploy Jenkins
ansible-playbook playbooks/jenkins.yml

# 2. Deploy Harbor Registry
ansible-playbook playbooks/harbor.yml

# 3. Deploy SonarQube
ansible-playbook playbooks/sonarqube.yml
```

### **Fase 3: GitOps & Deployment**
```bash
# 1. Deploy ArgoCD
kubectl apply -f manifests/argocd/

# 2. Configure GitOps repos
argocd app create sample-app --repo https://github.com/user/k8s-manifests

# 3. Deploy Helm charts
helm install monitoring prometheus-community/kube-prometheus-stack
```

### **Fase 4: Observability**
```bash
# 1. Deploy ELK Stack
kubectl apply -f manifests/elk/

# 2. Deploy Graylog
kubectl apply -f manifests/graylog/

# 3. Configure Jaeger
kubectl apply -f manifests/jaeger/
```

---

## 📊 Dashboards & Interfaces

### **URLs de Acesso**
```
Jenkins:     http://jenkins.lab.local
ArgoCD:      https://argocd.lab.local
Grafana:     http://grafana.lab.local
Kibana:      http://kibana.lab.local
Graylog:     http://graylog.lab.local:9000
Harbor:      https://harbor.lab.local
SonarQube:   http://sonar.lab.local:9000
Prometheus:  http://prometheus.lab.local:9090
```

### **Credenciais Padrão**
```
Jenkins:   admin / admin123
ArgoCD:    admin / (kubectl get secret argocd-initial-admin-secret)
Grafana:   admin / admin
Graylog:   admin / admin
Harbor:    admin / Harbor12345
SonarQube: admin / admin
```

---

## 🔧 Exercícios Práticos

### **Exercício 1: Pipeline End-to-End**
1. **Criar aplicação** Node.js simples
2. **Configurar Jenkins** pipeline
3. **Build & Test** automatizado
4. **Deploy via ArgoCD** no K8s
5. **Monitorar** com Prometheus/Grafana

### **Exercício 2: Incident Response**
1. **Simular falha** na aplicação
2. **Detectar via** alertas Prometheus
3. **Investigar logs** no ELK/Graylog
4. **Trace distribuído** com Jaeger
5. **Rollback via** ArgoCD

### **Exercício 3: Security Scanning**
1. **Scan de vulnerabilidades** com Trivy
2. **Análise de código** com SonarQube
3. **Runtime monitoring** com Falco
4. **Policy enforcement** com OPA
5. **Secrets management** com Vault

### **Exercício 4: Scaling & Performance**
1. **Load testing** com K6
2. **HPA configuration** no K8s
3. **Resource optimization**
4. **Performance monitoring**
5. **Capacity planning**

---

## 📚 Estrutura de Arquivos (Proposta Futura)

> **⚠️ IMPORTANTE**: Esta estrutura é **CONCEITUAL** e não está implementada. É um roadmap para evolução futura do lab.

```
lab-devops-sre/ (NÃO IMPLEMENTADO)
├── terraform/
│   ├── environments/
│   │   └── devops-lab.tfvars
│   ├── modules/
│   │   ├── ec2-instances/
│   │   ├── networking/
│   │   └── security/
│   └── main.tf
├── ansible/
│   ├── playbooks/
│   │   ├── base-system.yml
│   │   ├── jenkins.yml
│   │   ├── k8s-cluster.yml
│   │   └── monitoring.yml
│   ├── roles/
│   └── inventory/
├── k8s-manifests/
│   ├── argocd/
│   ├── monitoring/
│   ├── logging/
│   └── applications/
├── jenkins/
│   ├── pipelines/
│   ├── shared-libraries/
│   └── job-configs/
└── docs/
    ├── setup-guide.md
    ├── troubleshooting.md
    └── best-practices.md
```

**📁 Estrutura Atual Implementada:**
```
aws-lab/ (IMPLEMENTADO)
├── terraform/
├── ansible/
├── scripts/
└── weather-app/
```

---

## 🎯 Objetivos de Aprendizado

### **DevOps Skills**
✅ **CI/CD Pipelines** - Jenkins, GitLab CI
✅ **GitOps** - ArgoCD, Flux
✅ **Infrastructure as Code** - Terraform, Ansible
✅ **Container Orchestration** - Kubernetes, Helm

### **SRE Skills**
✅ **Monitoring** - Prometheus, Grafana, AlertManager
✅ **Logging** - ELK Stack, Graylog, Fluentd
✅ **Tracing** - Jaeger, Zipkin
✅ **Incident Response** - PagerDuty, Runbooks

### **Security Skills**
✅ **Container Security** - Trivy, Clair, Falco
✅ **Policy as Code** - OPA Gatekeeper
✅ **Secrets Management** - Vault, External Secrets
✅ **Compliance** - CIS Benchmarks, NIST

---

## 💰 Estimativa de Custos (AWS)

### **Instâncias EC2**
- 4x t3.medium: ~$120/mês
- 1x t3.large: ~$60/mês
- Storage (200GB): ~$20/mês
- **Total**: ~$200/mês

### **Otimizações**
- **Spot Instances**: -70% custo
- **Auto Shutdown**: Lambda às 18h
- **Reserved Instances**: -40% custo
- **Custo otimizado**: ~$60/mês

---

## 🚀 Próximos Passos

Quer que eu implemente este lab? Posso começar por:

1. **Atualizar Terraform** para as 4 instâncias
2. **Criar playbooks Ansible** para cada ferramenta
3. **Configurar K8s manifests** para deploy
4. **Documentar exercícios** práticos
5. **Criar pipelines** de exemplo