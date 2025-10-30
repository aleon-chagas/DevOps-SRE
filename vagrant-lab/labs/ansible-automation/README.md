# Ansible Lab Environment

Este projeto configura um ambiente de laboratório usando Vagrant e Ansible para demonstrar a automação de infraestrutura.

## Estrutura do Projeto

```
ansible-lab/
├── control-node/     # Nó de controle Ansible
├── app01/           # Servidor de aplicação
└── db01/            # Servidor de banco de dados
```

## Pré-requisitos

- Vagrant
- VirtualBox
- Ansible

## Configuração do Ambiente

1. Clone o repositório
2. Navegue até o diretório do projeto
3. Execute `vagrant up` para criar as máquinas virtuais
4. Acesse o nó de controle: `vagrant ssh control-node`

## Executando Playbooks

No nó de controle, execute os playbooks na seguinte ordem:

1. Configurar banco de dados:
```bash
ansible-playbook playbooks/db.yaml
```

2. Configurar aplicação:
```bash
ansible-playbook playbooks/app.yml
```

## Estrutura dos Playbooks

- `playbooks/db.yaml`: Configura o servidor MySQL
- `playbooks/app.yml`: Configura a aplicação Java Spring Boot

## Variáveis

As variáveis principais estão definidas em:
- `playbooks/vars/main.yml`
- Dentro dos próprios playbooks

## Roles

- `configuracao-default-so`: Configurações básicas do sistema operacional
- `geerlingguy.mysql`: Role para instalação e configuração do MySQL 