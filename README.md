# 🚀 DevOps/SRE Labs Completos

**Criado por:** Aleon Chagas  
**Versão:** 2.0.0  
**Especialista DevOps/SRE**

## 📋 Visão Geral

Repositório completo com labs práticos de DevOps/SRE para ambientes **AWS Cloud** e **Local (Vagrant)**. Infraestrutura como código, automação, Kubernetes, CI/CD, monitoramento e aplicações reais para aprendizado hands-on.

### **🎯 Objetivos**
- ✅ **Praticar DevOps/SRE** em ambientes reais
- ✅ **Comparar Cloud vs Local** - AWS vs Vagrant
- ✅ **Automatizar infraestrutura** - Terraform + Ansible
- ✅ **Deployar aplicações** - Kubernetes + Docker
- ✅ **Implementar CI/CD** - Jenkins + GitOps
- ✅ **Monitorar sistemas** - Prometheus + Grafana

### **🏗️ Arquitetura Geral**
```
┌─────────────────────────────────────────────────────────────────┐
│                     DevOps/SRE Labs                             │
├─────────────────────────────┬───────────────────────────────────┤
│         AWS Lab             │         Vagrant Lab               │
│    (Produção/Cloud)         │       (Local/Desenvolvimento)     │
├─────────────────────────────┼───────────────────────────────────┤
│ • Terraform + AWS           │ • Vagrant + VirtualBox            │
│ • 4x EC2 Instances          │ • VMs Locais                      │
│ • Auto-scaling              │ • Recursos limitados              │
│ • Custo: ~$60/mês           │ • Gratuito                        │
│ • Internet necessária       │ • Funciona offline                │
└─────────────────────────────┴───────────────────────────────────┘
```

---

## 📁 Estrutura do Repositório

```
DevOps-SRE/
├── aws-lab/                   # 🌩️ Lab AWS Cloud
│   ├── terraform/             # Infrastructure as Code
│   ├── ansible/               # Configuration Management
│   ├── scripts/               # Deploy/Destroy automation
│   ├── weather-app/           # Sample Application
│   └── README.md              # Documentação AWS
├── vagrant-lab/               # 💻 Lab Local
│   ├── labs/                  # Labs individuais
│   ├── shared/                # Recursos compartilhados
│   ├── weather-app/           # App adaptada para local
│   └── README.md              # Documentação Vagrant
├── shared-resources/          # 🔄 Recursos Compartilhados
│   ├── weather-app/           # Aplicação base
│   ├── ansible-roles/         # Roles reutilizáveis
│   └── scripts/               # Scripts comuns
├── docs/                      # 📚 Documentação
│   ├── pdfs/                  # Material didático
│   └── guides/                # Guias práticos
└── README.md                  # Esta documentação
```

---

## 🌩️ AWS Lab - Ambiente Cloud

### **Características**
- **Infraestrutura**: 4x EC2 instances (1 master + 3 workers)
- **Automação**: Terraform + Ansible
- **Kubernetes**: K3s cluster
- **Monitoramento**: Prometheus + Grafana
- **Aplicação**: Weather Dashboard
- **Custo**: ~$60/mês (otimizado)

### **Quick Start**
```bash
cd aws-lab
cd scripts && bash deploy.sh dev
```

### **Ideal para:**
- ✅ **Ambiente de produção**
- ✅ **Aprendizado de cloud**
- ✅ **Escalabilidade real**
- ✅ **Integração com serviços AWS**

---

## 💻 Vagrant Lab - Ambiente Local

### **Características**
- **Virtualização**: VirtualBox + Vagrant
- **Labs**: K3s, Jenkins, Monitoring, Docker Swarm
- **Recursos**: Configuráveis (8-16GB RAM)
- **Aplicação**: Weather Dashboard local
- **Custo**: Gratuito

### **Quick Start**
```bash
cd vagrant-lab/labs/k3s-cluster
vagrant up
```

### **Ideal para:**
- ✅ **Desenvolvimento local**
- ✅ **Aprendizado sem custos**
- ✅ **Experimentação segura**
- ✅ **Trabalho offline**

---

## 🌤️ Weather App - Aplicação Demonstrativa

### **Funcionalidades**
- **Frontend**: React SPA com geolocalização
- **Backend**: Node.js API com métricas Prometheus
- **Cache**: Redis para performance
- **APIs**: OpenWeatherMap + IP-API
- **Monitoramento**: Métricas customizadas

### **Deployments**
- **AWS**: Kubernetes K3s na nuvem
- **Local**: Kubernetes K3s via Vagrant
- **Docker**: Compose para desenvolvimento

---

## 🚀 Comandos Rápidos

### **AWS Lab**
```bash
# Deploy completo
cd aws-lab/scripts && bash deploy.sh dev

# Destruir tudo
bash destroy.sh dev

# Acessar aplicação
K8S_IP=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=k8s-master" "Name=instance-state-name,Values=running" --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
echo "Weather App: http://$K8S_IP:30080"
```

### **Vagrant Lab**
```bash
# Deploy K3s cluster
cd vagrant-lab/labs/k3s-cluster && vagrant up

# Acessar aplicação
echo "Weather App: http://192.168.56.10:30080"

# Destruir VMs
vagrant destroy -f
```

---

## 📊 Comparação Detalhada

| Aspecto | AWS Lab | Vagrant Lab |
|---------|---------|-------------|
| **Custo** | ~$60/mês | Gratuito |
| **Setup** | 15 min | 10 min |
| **Recursos** | Ilimitados | Hardware local |
| **Internet** | Necessária | Opcional |
| **Escalabilidade** | Auto-scaling | Manual |
| **Persistência** | Sempre ativo | Sob demanda |
| **Realismo** | Produção | Desenvolvimento |
| **Experimentação** | Cuidado com custos | Livre |

---

## 🎓 Roteiro de Aprendizado

### **Iniciante**
1. **Vagrant Lab** - K3s cluster local
2. **Weather App** - Deploy básico
3. **Monitoramento** - Prometheus + Grafana
4. **Conceitos** - Kubernetes, Docker, Ansible

### **Intermediário**
5. **AWS Lab** - Infraestrutura cloud
6. **Terraform** - Infrastructure as Code
7. **CI/CD** - Jenkins pipelines
8. **Scaling** - HPA e load testing

### **Avançado**
9. **Security** - Vault, Falco, OPA
10. **Logging** - ELK Stack
11. **Service Mesh** - Istio + Jaeger
12. **GitOps** - ArgoCD

---

## 🛠️ Pré-requisitos

### **Para AWS Lab**
```bash
# Ferramentas necessárias
terraform --version  # >= 1.0
ansible --version    # >= 2.9
aws --version        # >= 2.0
kubectl --version    # >= 1.20

# Credenciais AWS configuradas
aws sts get-caller-identity
```

### **Para Vagrant Lab**
```bash
# Ferramentas necessárias
vagrant --version     # >= 2.2
vboxmanage --version  # >= 6.0

# Recursos mínimos
# RAM: 8GB (16GB recomendado)
# CPU: 4 cores (8 cores recomendado)
# Disk: 20GB livre (50GB recomendado)
```

---

## 🔧 Configuração Inicial

### **1. Clonar Repositório**
```bash
git clone <repo-url>
cd DevOps-SRE
```

### **2. Configurar AWS (se usar AWS Lab)**
```bash
# Configurar credenciais
aws configure

# Registrar API key OpenWeatherMap
export OPENWEATHER_API_KEY="sua-api-key"
```

### **3. Escolher Lab**
```bash
# Para AWS
cd aws-lab && cat README.md

# Para Local
cd vagrant-lab && cat README.md
```

---

## 🐛 Troubleshooting Comum

### **AWS Lab**
```bash
# Instâncias não criam
aws sts get-caller-identity  # Verificar credenciais
aws ec2 describe-regions     # Verificar região

# Terraform falha
terraform state list         # Verificar state
terraform refresh            # Atualizar state
```

### **Vagrant Lab**
```bash
# VMs não iniciam
vboxmanage list vms         # Verificar VirtualBox
vagrant global-status       # Verificar status

# Recursos insuficientes
# Aumentar RAM/CPU no Vagrantfile
# Fechar outras aplicações
```

---

## 📚 Recursos de Aprendizado

### **Documentação**
- [AWS Lab](./aws-lab/README.md) - Guia completo AWS
- [Vagrant Lab](./vagrant-lab/README.md) - Guia completo Local
- [Weather App](./shared-resources/weather-app/) - Aplicação base

### **Material Didático**
- [PDFs](./docs/pdfs/) - Slides e apresentações
- [Guias](./docs/guides/) - Tutoriais passo a passo

### **Links Externos**
- [Kubernetes Docs](https://kubernetes.io/docs/)
- [Terraform Docs](https://www.terraform.io/docs/)
- [Ansible Docs](https://docs.ansible.com/)
- [Vagrant Docs](https://www.vagrantup.com/docs)

---

## 🚀 Próximos Passos

### **Labs Implementados**
- ✅ **AWS Lab** - Infraestrutura cloud completa
- ✅ **Vagrant Lab** - Ambiente local funcional
- ✅ **Weather App** - Aplicação demonstrativa
- ✅ **Monitoramento** - Prometheus + Grafana

### **Roadmap Futuro**
- 🔄 **Security Labs** - Vault + Falco + OPA
- 🔄 **Logging Stack** - ELK + Graylog
- 🔄 **Service Mesh** - Istio + Jaeger
- 🔄 **GitOps** - ArgoCD + Flux
- 🔄 **Chaos Engineering** - Chaos Monkey
- 🔄 **Multi-cloud** - Azure + GCP labs

---

## 🤝 Contribuição

### **Como Contribuir**
1. **Fork** o repositório
2. **Crie branch** para sua feature
3. **Teste** as mudanças
4. **Envie PR** com descrição detalhada

### **Áreas de Contribuição**
- 🐛 **Bug fixes** - Correções e melhorias
- 📚 **Documentação** - Guias e tutoriais
- 🚀 **Novos labs** - Ferramentas adicionais
- 🔧 **Otimizações** - Performance e recursos

---

**💡 Labs criados por Aleon Chagas - Experiência completa de DevOps/SRE para todos os níveis!**

## 👨💻 Sobre o Autor

**Aleon Chagas** é especialista em DevOps/SRE com ampla experiência em:
- ☁️ **Cloud Computing** (AWS, Azure, GCP)
- 💻 **Virtualização** (Vagrant, VirtualBox, VMware)
- 🔧 **Infrastructure as Code** (Terraform, CloudFormation)
- 🚀 **CI/CD Pipelines** (Jenkins, GitLab, GitHub Actions)
- ⚙️ **Container Orchestration** (Kubernetes, Docker Swarm)
- 📈 **Monitoring & Observability** (Prometheus, Grafana, ELK)

---

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para detalhes.