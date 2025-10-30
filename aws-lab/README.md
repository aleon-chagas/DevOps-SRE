# 🚀 Lab DevOps/SRE Completo

**Criado por:** Aleon Chagas
**Versão:** 2.0.0
**Especialista DevOps/SRE**

## 📋 Visão Geral

Lab completo de DevOps/SRE com infraestrutura AWS, Kubernetes K3s, aplicação Weather Dashboard, monitoramento Prometheus/Grafana e automação completa via Terraform + Ansible.

> **⚠️ IMPORTANTE**: Este é o lab **AWS CLOUD**. Para ambiente local, consulte `../vagrant-lab/`. Para ferramentas avançadas, consulte `LAB-DEVOPS-SRE.md` (roadmap futuro).

### **🎯 Objetivos**
- ✅ **Provisionar** infraestrutura AWS com Terraform
- ✅ **Automatizar** configuração com Ansible  
- ✅ **Deployar** aplicações no Kubernetes
- ✅ **Implementar** monitoramento com Prometheus
- ✅ **Aplicar** boas práticas de segurança

### **🏗️ Arquitetura**
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Terraform     │───▶│     Ansible     │───▶│   Kubernetes    │
│ (Infraestrutura)│    │ (Configuração)  │    │  (Aplicações)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
    AWS EC2/VPC            K3s Cluster              Weather App
    S3/DynamoDB           Docker/kubectl           Prometheus/Grafana
```

---

## ⚡ Quick Start

### **1. Deploy Completo**
```bash
# Clonar repositório
git clone <repo-url>
cd DevOps-SRE/aws-lab

# Deploy infraestrutura + aplicação
cd scripts && bash deploy.sh dev

# Aguardar ~15 minutos para conclusão
```

### **2. Acessar Aplicações**
```bash
# Obter IP do cluster
K8S_IP=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=k8s-master" "Name=instance-state-name,Values=running" --query "Reservations[0].Instances[0].PublicIpAddress" --output text)

# URLs de acesso
echo "Weather App: http://$K8S_IP:30080"
echo "Grafana: http://$K8S_IP:30300 (admin/admin123)"
echo "Prometheus: http://$K8S_IP:30900"
```

### **3. Limpeza**
```bash
# Destruir tudo
cd scripts && bash destroy.sh dev
```

---

## 🛠️ Componentes

### **📁 Estrutura do Projeto**
```
aws-lab/
├── terraform/                  # Terraform Infrastructure
│   ├── remote-backend-stack/   # S3 + DynamoDB
│   ├── network-stack/          # VPC + Subnets
│   └── main-stack/             # EC2 + Security Groups
├── ansible/                    # Ansible Automation
│   ├── deploy/roles/           # Roles (K3s, Apps, Monitoring)
│   ├── playbooks/              # Playbooks específicos
│   ├── site.yml                # Setup básico K3s
│   └── k3s-setup.yml           # Setup completo
├── weather-app/                # Aplicação Weather Dashboard
│   ├── frontend/               # React SPA
│   ├── backend/                # Node.js API
│   └── k8s-manifests/          # Kubernetes YAML
├── scripts/                    # Scripts de automação
│   ├── deploy.sh               # Deploy completo
│   └── destroy.sh              # Limpeza completa
└── README.md                   # Esta documentação
```

### **🌤️ Weather App**
- **Frontend**: React SPA com geolocalização
- **Backend**: Node.js API com métricas Prometheus
- **Cache**: Redis para performance
- **APIs**: OpenWeatherMap + IP-API para localização

### **☁️ Infraestrutura AWS**
- **Compute**: 4x EC2 (1 master + 3 workers)
- **Network**: VPC dedicada com subnets públicas
- **Storage**: S3 (Terraform state) + DynamoDB (lock)
- **Security**: Security Groups com portas controladas
- **Automation**: Lambda para auto-shutdown às 18h BRT

### **🔧 Ferramentas Implementadas (Lab Atual)**
```
✅ Terraform       - Infrastructure as Code
✅ Ansible         - Configuration Management
✅ K3s             - Lightweight Kubernetes
✅ Prometheus      - Metrics Collection
✅ Grafana         - Visualization
✅ Redis           - Caching
✅ Weather App     - Sample Application
```

### **🚀 Ferramentas Futuras (Roadmap)**
```
❌ Jenkins         - CI/CD Pipelines
❌ ArgoCD          - GitOps Deployment
❌ Harbor          - Container Registry
❌ Jaeger          - Distributed Tracing
❌ ELK Stack       - Centralized Logging
❌ Vault           - Secrets Management
❌ Falco           - Runtime Security
❌ SonarQube       - Code Quality
```
> **Ver `LAB-DEVOPS-SRE.md` para implementação futura dessas ferramentas**

### **🔧 Ambientes Disponíveis**
```bash
# dev: 2x t3.micro (Free Tier)
# stg: 4x t3.small (Staging)  
# prod: 4x t3.medium (Production)
```

---

## 🚀 Comandos Essenciais

### **Infraestrutura**
```bash
# Deploy completo
cd scripts && bash deploy.sh dev

# Destruir tudo
bash destroy.sh dev

# Deletar apenas instâncias EC2 (manter VPC, S3, etc)
cd terraform/main-stack
terraform destroy -target=aws_instance.k8s_master -target=aws_instance.k8s_workers -var-file=environments/dev.tfvars

# Se Terraform não encontrar as instâncias, usar AWS CLI:
INSTANCE_IDS=$(aws ec2 describe-instances --filters "Name=tag:Environment,Values=dev" "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*].InstanceId" --output text)
if [ ! -z "$INSTANCE_IDS" ]; then
  aws ec2 terminate-instances --instance-ids $(echo $INSTANCE_IDS | tr '\n' ' ')
else
  echo "Nenhuma instância encontrada"
fi

# Recriar apenas instâncias EC2
terraform apply -var-file=environments/dev.tfvars

# Atualizar IPs + SSH config
cd ../../ansible && ./update-inventory.sh

# Testar conectividade
ansible all -m ping

# Limpar arquivos Terraform (se necessário)
find . -name ".terraform" -type d -exec rm -rf {} +
find . -name "terraform.tfstate*" -delete
find . -name ".terraform.lock.hcl" -delete
```

### **Aplicação Weather**
```bash
# Deploy aplicação
cd ansible
ansible-playbook playbooks/weather-app.yml

# Deploy completo (K3s + Weather App + Monitoring)
ansible-playbook k3s-setup.yml

# Verificar pods
ansible master -m shell -a "kubectl get pods -n weather-app" -b --become-user=ubuntu

# Ver logs
ansible master -m shell -a "kubectl logs -f deployment/weather-api -n weather-app" -b --become-user=ubuntu

# Definir namespace weather-app como padrão
ansible master -m shell -a "kubectl config set-context --current --namespace=weather-app" -b --become-user=ubuntu
```

### **Kubernetes**
```bash
# Pods por namespace
kubectl get pods --all-namespaces

# Ver pods de todos os namespaces
kubectl get pods --all-namespaces

# Ver pods do namespace weather-app
kubectl get pods -n weather-app

# Definir weather-app como namespace padrão
kubectl config set-context --current --namespace=weather-app

# Descrever recurso
kubectl describe pod <pod-name> -n <namespace>

# Logs em tempo real
kubectl logs -f deployment/<name> -n <namespace>

# Executar comando no pod
kubectl exec -it <pod-name> -n <namespace> -- /bin/bash

# Escalar deployment
kubectl scale deployment <name> --replicas=3 -n <namespace>

# Copiar kubeconfig do master para workers (se necessário)
scp -i ~/.ssh/ssh_keys/courses/devops2025.pem ubuntu@k8s-master:/home/ubuntu/.kube/config ~/.kube/config
ansible workers -m copy -a "src=~/.kube/config dest=/home/ubuntu/.kube/config owner=ubuntu group=ubuntu mode=0600" -b
```

### **Monitoramento**
```bash
# Instalar Prometheus stack
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring --create-namespace

# Expor Grafana
kubectl patch svc monitoring-grafana -n monitoring -p '{"spec":{"type":"NodePort","ports":[{"port":80,"targetPort":3000,"nodePort":30300}]}}'

# Senha Grafana
kubectl get secret monitoring-grafana -n monitoring -o jsonpath='{.data.admin-password}' | base64 -d
```

---

## 🔧 URLs Importantes

### **Aplicação**
- **Weather App**: `http://<K8S_IP>:30080`
- **API Health**: `http://<K8S_IP>:30080/api/health`
- **Métricas**: `http://<K8S_IP>:30080/api/metrics`

### **Monitoramento**
- **Grafana**: `http://<K8S_IP>:30300` (admin/password)
- **Prometheus**: `http://<K8S_IP>:30900`

### **Security Group - Portas Liberadas**
```
# Acesso externo (seu IP)
22    - SSH
30080 - Weather App
30300 - Grafana
30900 - Prometheus
6443  - Kubernetes API
3001  - Weather API
8080  - Weather Frontend
6379  - Redis

# Entre instâncias
0-65535 TCP/UDP - Tráfego completo
ICMP - Ping
```

### **APIs Externas**
- **OpenWeatherMap**: https://openweathermap.org/api
- **IP Geolocation**: http://ip-api.com/

---

## 🐛 Troubleshooting

### **Pods não iniciam**
```bash
# Verificar
kubectl describe pod <pod-name> -n <namespace>
kubectl get events -n <namespace>

# Soluções
- Verificar resource limits
- Checar imagem existe
- Validar secrets/configmaps
```

### **Aplicação não responde**
```bash
# Verificar
kubectl get svc -n <namespace>
kubectl get endpoints -n <namespace>

# Soluções
- Verificar labels/selectors
- Testar conectividade interna
- Checar health checks
```

### **Terraform não encontra instâncias**
```bash
# Verificar state do Terraform
terraform state list

# Se vazio, instâncias foram criadas fora do Terraform
# Listar instâncias por tag
aws ec2 describe-instances --filters "Name=tag:Project,Values=devops-lab" "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*].[InstanceId,Tags[?Key=='Name'].Value|[0]]" --output table

# Deletar via AWS CLI
INSTANCE_IDS=$(aws ec2 describe-instances --filters "Name=tag:Project,Values=devops-lab" "Name=instance-state-name,Values=running" --query "Reservations[*].Instances[*].InstanceId" --output text)
if [ ! -z "$INSTANCE_IDS" ]; then
  aws ec2 terminate-instances --instance-ids $(echo $INSTANCE_IDS | tr '\n' ' ')
else
  echo "Nenhuma instância encontrada"
fi
```

### **K3s Issues**
```bash
# Status do K3s
ansible master -m shell -a "sudo systemctl status k3s" -b

# Logs do K3s
ansible master -m shell -a "sudo journalctl -u k3s -f" -b

# Reiniciar K3s
ansible master -m shell -a "sudo systemctl restart k3s" -b

# Verificar cluster K3s
ansible master -m shell -a "sudo systemctl status k3s"
ansible k8s_workers -m shell -a "sudo systemctl status k3s-agent"
```

---

## 📊 Métricas Importantes

### **Weather App**
```
weather_api_requests_total
weather_api_request_duration_seconds
weather_cache_hits_total
weather_cache_misses_total
weather_external_api_calls_total
```

### **Kubernetes**
```
container_cpu_usage_seconds_total
container_memory_usage_bytes
kube_pod_status_ready
kube_deployment_status_replicas
```

---

## 🔐 Secrets & ConfigMaps

### **Criar Secret**
```bash
kubectl create secret generic weather-secrets \
  --from-literal=OPENWEATHER_API_KEY=your-key \
  -n weather-app
```

### **Atualizar Secret**
```bash
kubectl patch secret weather-secrets -n weather-app \
  -p '{"data":{"OPENWEATHER_API_KEY":"'$(echo -n "new-key" | base64)'"}}'
```

---

## 🎓 Guia de Aula

### **Duração:** 3-4 horas
### **Nível:** Intermediário/Avançado

### **Roteiro:**

#### **PARTE 1: Preparação (15 min)**
```bash
# Verificar ferramentas
terraform --version
ansible --version
kubectl version --client
aws --version

# Configurar API key OpenWeatherMap
export OPENWEATHER_API_KEY="sua-api-key-aqui"
```

#### **PARTE 2: Infraestrutura (30 min)**
```bash
cd scripts
bash deploy.sh dev

# Verificar instâncias
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress,Tags[?Key==`Name`].Value|[0]]' --output table

cd ../ansible
./update-inventory.sh
ansible all -m ping
```

#### **PARTE 3: Aplicação (45 min)**
```bash
# Deploy Weather App
ansible-playbook k3s-setup.yml

# Verificar deploy
ansible master -m shell -a "kubectl get pods -n weather-app" -b --become-user=ubuntu

# Obter URL
K8S_IP=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=k8s-master" "Name=instance-state-name,Values=running" --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
echo "Aplicação disponível em: http://$K8S_IP:30080"

# Testar API
curl http://$K8S_IP:30080/api/health
```

#### **PARTE 4: Monitoramento (45 min)**
```bash
# URLs de acesso
echo "Grafana: http://$K8S_IP:30300 (admin/admin123)"
echo "Prometheus: http://$K8S_IP:30900"

# Verificar métricas
curl http://$K8S_IP:30080/api/metrics
```

#### **PARTE 5: Cenários Práticos (45 min)**
```bash
# Scaling
ansible master -m shell -a "kubectl scale deployment weather-frontend --replicas=4 -n weather-app" -b --become-user=ubuntu

# Simulação de falha
ansible master -m shell -a "kubectl delete pod -l app.kubernetes.io/name=weather-api -n weather-app --force --grace-period=0" -b --become-user=ubuntu

# Verificar recuperação
ansible master -m shell -a "kubectl get pods -n weather-app -w" -b --become-user=ubuntu
```

---

## 🛡️ Security Checklist

### **Kubernetes Security**
- ✅ Non-root containers
- ✅ Read-only root filesystem
- ✅ Resource limits
- ✅ Network policies
- ✅ Pod security contexts
- ✅ Secrets não em plain text

### **Application Security**
- ✅ Rate limiting
- ✅ Input validation
- ✅ HTTPS/TLS
- ✅ Security headers
- ✅ Dependency scanning
- ✅ Container scanning

---

## 📚 Links Úteis

### **Documentação**
- [Kubernetes Docs](https://kubernetes.io/docs/)
- [Prometheus Docs](https://prometheus.io/docs/)
- [Grafana Docs](https://grafana.com/docs/)
- [Ansible Docs](https://docs.ansible.com/)

### **Ferramentas**
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Helm Charts](https://artifacthub.io/)
- [Prometheus Exporters](https://prometheus.io/docs/instrumenting/exporters/)

---

## 🚀 Próximos Passos

### **Lab Atual (Implementado)**
- ✅ **Terraform + Ansible** - Infraestrutura automatizada
- ✅ **K3s Cluster** - Kubernetes funcional
- ✅ **Weather App** - Aplicação completa
- ✅ **Prometheus + Grafana** - Monitoramento básico

### **Evolução Futura (Roadmap)**
- 🔄 **Jenkins** - CI/CD pipelines
- 🔄 **ArgoCD** - GitOps deployment
- 🔄 **Harbor** - Container registry
- 🔄 **Vault** - Secrets management
- 🔄 **Jaeger** - Distributed tracing
- 🔄 **ELK Stack** - Centralized logging
- 🔄 **Falco** - Runtime security

> **📄 Para implementação das ferramentas avançadas, consulte `LAB-DEVOPS-SRE.md`**

---

**💡 Lab criado por Aleon Chagas - Experiência completa de DevOps/SRE com ferramentas reais de mercado!**

## 👨💻 Sobre o Autor

**Aleon Chagas** é especialista em DevOps/SRE com ampla experiência em:
- ☁️ **Cloud Computing** (AWS, Azure, GCP)
- 🔧 **Infrastructure as Code** (Terraform, CloudFormation)
- 🚀 **CI/CD Pipelines** (Jenkins, GitLab, GitHub Actions)
- ⚙️ **Container Orchestration** (Kubernetes, Docker)
- 📈 **Monitoring & Observability** (Prometheus, Grafana, ELK)