# Terraform Network Stack

Esta stack do Terraform é responsável por provisionar a infraestrutura de rede fundamental na AWS.

## Propósito

O objetivo é gerenciar recursos de rede de base (VPC, Subnets, etc.) de forma separada das stacks de aplicação. Isso segue a melhor prática de separação de interesses, onde a infraestrutura de rede, que muda com menos frequência, não é misturada com os recursos de aplicação.

## Recursos Criados

- **VPC Principal:** Uma VPC com o CIDR block `10.0.0.0/16`.
- **Subnets:** Três subnets, cada uma em uma Zona de Disponibilidade (AZ) diferente para alta disponibilidade:
  - **dev:** `10.0.1.0/24`
  - **stg:** `10.0.2.0/24`
  - **prod:** `10.0.3.0/24`

## Como Usar

1.  **Inicialize o Terraform** neste diretório:
    ```bash
    terraform init
    ```

2.  **Planeje e revise as mudanças**:
    ```bash
    terraform plan
    ```

3.  **Aplique a configuração** para criar a VPC e as subnets:
    ```bash
    terraform apply
    ```

## Outputs

Esta stack exporta os seguintes outputs, que podem ser consumidos por outras stacks (como a `main-stack`) usando um data source `terraform_remote_state`.

- `vpc_id`: O ID da VPC criada.
- `subnet_ids_map`: Um mapa que associa cada ambiente ao seu respectivo ID de subnet.
  - **Exemplo:** `{ "dev" = "subnet-xxxx", "stg" = "subnet-yyyy", "prod" = "subnet-zzzz" }`
