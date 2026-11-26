# Gerenciador de Quadras

Sistema de agendamento de quadras esportivas, desenvolvido na disciplina de Gerência de Projetos de Software (UFOP).
O dono da quadra cadastra quadras, funcionários e clientes e acompanha relatórios; os clientes agendam horários
pelo aplicativo; os funcionários validam a entrada.

| Pasta | O que é | Tecnologias |
| --- | --- | --- |
| `backend/` | API REST | Dart, Shelf, ORM `orm`, PostgreSQL 18 |
| `gerenciamento_de_quadras/` | Aplicativo Android | Flutter |
| `docker-compose.yml` | Banco de dados e servidor de email de testes | Docker |

## Pré-requisitos

- [Git](https://git-scm.com/downloads)
- [Flutter](https://docs.flutter.dev/get-started/install) (já inclui o Dart; o backend exige **Dart 3.13.4 ou mais novo**)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- Android Studio com um emulador Android configurado (para rodar o aplicativo)

## 1. Banco de dados e backend

Todos os comandos abaixo partem da raiz do projeto. O Docker Desktop precisa estar aberto.

**1.1. Criar o arquivo de configuração** (só na primeira vez):

```bash
cp .env.example .env        # Linux/macOS
copy .env.example .env      # Windows
```

Os valores do `.env.example` já funcionam para rodar localmente.

**1.2. Subir o banco de dados e o servidor de email de testes:**

```bash
docker compose up -d
```

**1.3. Instalar as dependências e criar as tabelas:**

```bash
cd backend
dart pub get
dart run orm.config.dart migrate apply
```

**1.4. Criar os dados de exemplo** (usuários e uma quadra, veja a seção 2):

```bash
dart run bin/popular_banco.dart
```

**1.5. Iniciar a API:**

```bash
dart run bin/backend.dart
```

Quando aparecer `Servidor iniciado na porta 8080`, a API está no ar em http://localhost:8080. Deixe esse terminal aberto.

> Depois de cada `git pull`, rode de novo os comandos do passo 1.3: pode haver dependências ou tabelas novas.

## 2. Usuários de exemplo

Criados pelo comando `dart run bin/popular_banco.dart`. Rodar de novo não duplica nada.

| Perfil | Email | Senha | O que pode fazer |
| --- | --- | --- | --- |
| Gerente | `gerente@quadras.com` | `Senha@123` | Gerenciar quadras, clientes e funcionários; ver relatórios |
| Funcionário | `funcionario@quadras.com` | `Senha@123` | Ver os agendamentos e validar a entrada |
| Cliente | `cliente@quadras.com` | `Senha@123` | Agendar, editar e cancelar os próprios horários |

O script também cria a **Quadra Exemplo**, aberta todos os dias das 08:00 às 22:00, com sessões de 60 minutos.

Esses usuários existem só no banco local de cada máquina e servem apenas para desenvolvimento e testes.

## 3. Aplicativo (frontend)

Com a API rodando, em outro terminal:

```bash
cd gerenciamento_de_quadras
flutter run
```

O aplicativo acessa a API em `http://10.0.2.2:8080`, que é o endereço do computador visto de dentro do **emulador Android**.
Para usar um celular de verdade, troque `baseUrl` em `gerenciamento_de_quadras/lib/core/services/auth_service.dart`
pelo IP do computador na rede (por exemplo `http://192.168.0.15:8080`), com o celular no mesmo Wi-Fi.

## Endereços úteis

| Endereço | O que é |
| --- | --- |
| http://localhost:8080 | API |
| http://localhost:8025 | Caixa de emails de teste (Mailpit): os emails de criar e redefinir senha chegam aqui |
| `127.0.0.1:5432` | Banco PostgreSQL (usuário `postgres`, senha `postgres`, banco `gerenciador_quadras`) |

Exemplos de chamadas da API estão em `backend/requisicoes.http` e podem ser executados no VS Code com a extensão
**REST Client**.

## Problemas comuns

| Mensagem ou sintoma | Causa | Solução |
| --- | --- | --- |
| `Não foi possível conectar ao banco de dados` ou `O computador remoto recusou a conexão` | Banco desligado | Abrir o Docker Desktop e rodar `docker compose up -d` |
| `failed to connect to the docker API` | Docker Desktop fechado | Abrir o Docker Desktop e esperar carregar |
| `Missing extension byte` ao conectar | Um PostgreSQL instalado no Windows está ocupando a porta 5432 | Parar o serviço `postgresql-x64-...` em `services.msc` |
| `relation "..." does not exist` | Faltam tabelas | `dart run orm.config.dart migrate apply` dentro de `backend/` |
| Login falha com os usuários de exemplo | Dados de exemplo não criados | `dart run bin/popular_banco.dart` dentro de `backend/` |
| O aplicativo não conecta na API | API desligada, ou endereço errado para o aparelho | Conferir se `dart run bin/backend.dart` está rodando e o `baseUrl` (seção 3) |
