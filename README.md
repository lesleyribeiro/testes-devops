# Projeto Terraform - DevOps Teste

## Introdução
Esse projeto foi criado para o desafio de DevOps, com o objetivo de configurar uma infraestrutura na AWS usando Terraform. A ideia aqui é ter uma estrutura modular e fácil de entender.

## Como baixar e utilizar o código
- Clone o repositório.
- Vá até o diretório environment/dev.
- Execute **terraform init** para preparar o ambiente e iniciar os módulos.
- Execute **terraform plan** para ver o que será criado.
- Execute **terraform apply** para criar a infraestrutura.

## Estrutura do Projeto
- **modules/**: Aqui ficam os módulos que podem ser reutilizados, como o EKS, WordPress eo RDS.
- **environment/dev/**: Configurações específicas do ambiente de desenvolvimento.
- **main.tf**: Arquivo principal onde defino os recursos.
- **variables.tf**: Variáveis que podem ser ajustadas conforme o ambiente.
- **outputs.tf**: Informações importantes que aparecem depois de rodar o Terraform.

## O que você precisa antes de começar
- Terraform v1.9.4
- AWS CLI configurado com suas credenciais
- Permissões na AWS para criar recursos (EC2, VPC, EKS, etc.)

## Como rodar o projeto
1. Clone o repositório.
2. Vá até o diretório `environment/dev`.
3. Confira e ajuste as variáveis no arquivo `variables.tf`.
4. Execute `terraform init` para preparar o ambiente e iniciar os modulos.
5. Execute `terraform plan` para ver o que será criado.
6. Execute `terraform apply` para criar a infraestrutura.

## Os modulos utilizados
### EKS
Esse módulo cria o cluster Kubernetes e os recursos que ele precisa, como a VPC, subnets, e grupos de segurança.

### WordPress
Aqui é onde configuro o serviço do WordPress no Kubernetes, usando um LoadBalancer para deixar ele acessível pela internet.

### Considerações finais
Esse projeto foi feito para ser simples e direto, seguindo as boas práticas do Terraform. Se surgir qualquer dúvida, fique a vontade para me procurar!
