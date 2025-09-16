# Sistema de Pedidos de Venda - Teste Técnico

Este projeto foi desenvolvido como parte de um teste técnico para a vaga de Desenvolvedor Delphi. O objetivo é demonstrar habilidades em desenvolvimento de software utilizando a linguagem Delphi e boas práticas de arquitetura, como POO, MVC e Clean Code.

A aplicação consiste em uma tela de gerenciamento de pedidos de venda, permitindo a criação, consulta e cancelamento de pedidos, além da manipulação completa dos itens do pedido.

## 📋 Funcionalidades

* Criação de novos pedidos de venda.
* Seleção de clientes a partir de uma lista pré-carregada.
* Busca de produtos por código.
* Adição, edição e exclusão de itens na grade do pedido.
* Cálculo automático do valor total do item e do pedido.
* Consulta de pedidos já gravados por número.
* Cancelamento (exclusão) de pedidos existentes.
* Configuração dinâmica da conexão com o banco de dados através de um arquivo `.ini`.

## 🛠️ Tecnologias e Stack

* **Linguagem:** Delphi 10.4 (utilizando o framework VCL)
* **Banco de Dados:** MySQL 5.7
* **Acesso a Dados:** FireDAC
* **Containerização:** Docker e Docker Compose

## 🏛️ Arquitetura e Boas Práticas

O projeto foi estruturado seguindo princípios modernos de arquitetura de software para garantir um código limpo, testável e de fácil manutenção.

* **MVC (Model-View-Controller):** A aplicação é dividida em três camadas distintas:
    * **Model:** Classes puras que representam as entidades de negócio (`TPedido`, `TCliente`, etc.).
    * **View:** O formulário principal, responsável apenas por exibir os dados e capturar as interações do usuário.
    * **Controller:** O cérebro da aplicação, que orquestra a comunicação entre a View e o Model/Repositórios.
* **POO (Programação Orientada a Objetos):** Utilização de classes, encapsulamento, herança e interfaces para modelar o domínio da aplicação.
* **Injeção de Dependência (DI):** As dependências (como os repositórios de dados) são injetadas nas classes que as utilizam (como o Controller), promovendo baixo acoplamento.
* **Padrão Repositório:** O acesso aos dados é abstraído por meio de interfaces (`IRepositorioPedidos`, etc.), escondendo a complexidade da camada de persistência.
* **Clean Code:** Adoção de práticas como nomes claros para variáveis e métodos, funções pequenas e com responsabilidade única (SRP).

## 🚀 Como Executar o Projeto

Siga os passos abaixo para configurar e executar a aplicação em seu ambiente local.

### Pré-requisitos

* Docker e Docker Compose instalados.
* RAD Studio / Delphi (versão 10.x ou superior).
* A biblioteca `libmysql.dll` de **32-bits** (necessária para a conexão via FireDAC).

### 1. Preparar o Ambiente do Banco de Dados

O projeto utiliza Docker para provisionar o banco de dados MySQL de forma rápida e isolada.

No terminal, navegue até a pasta raiz do projeto (onde o arquivo `docker-compose.yml` está localizado) e execute o seguinte comando:

```sh
docker-compose up -d
```

Este comando irá:
1.  Baixar a imagem do `mysql:5.7`, se ela não existir localmente.
2.  Iniciar um container chamado `mysql-delphi`.
3.  Criar um banco de dados chamado `pedidosdb`.
4.  Executar automaticamente os scripts SQL localizados na pasta `/initdb` para criar as tabelas e popular o banco com dados de teste.
5.  Mapear a porta `3306` do container para a porta `3306` da sua máquina.

### 2. Configurar a Conexão

1.  Verifique se o arquivo `libmysql.dll` de 32-bits está na pasta `App/`.
2.  Verifique o arquivo `database.ini` localizado na pasta `App/`. Os valores padrão já estão configurados para se conectar ao container Docker.

### 3. Compilar e Executar

1.  Abra o arquivo de projeto `SistemaPedidos.dproj` no Delphi.
2.  Compile o projeto (**Project > Build SistemaPedidos**).
3.  Execute a aplicação (**Run > Run** ou F9).
