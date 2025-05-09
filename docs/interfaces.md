# Interfaces do Sistema Administrativo

## 1. Telas de Autenticação

### 1.1 Tela de Login
- **Header**
  - Logo do sistema
  - Título "Admin System"

- **Formulário de Login**
  - Campo de email
    - Input type: email
    - Validação de formato
    - Placeholder: "Digite seu email"
  
  - Campo de senha
    - Input type: password
    - Validação de força
    - Placeholder: "Digite sua senha"
    - Ícone para mostrar/ocultar senha
  
  - Botão "Entrar"
    - Estado: disabled até preenchimento válido
    - Feedback visual durante processamento
  
  - Link "Esqueceu a senha?"
    - Redireciona para recuperação

- **Footer**
  - Link para registro de novo moderador
  - Versão do sistema

### 1.2 Tela de Registro de Moderador
- **Header**
  - Logo do sistema
  - Título "Registro de Moderador"

- **Formulário de Registro**
  - Informações Pessoais
    - Nome completo
    - Email
    - Telefone
    - Senha e confirmação
  
  - Botão "Registrar"
    - Validação de todos os campos
    - Feedback de progresso

## 2. Dashboard Principal

### 2.1 Header
- **Barra Superior**
  - Logo do sistema
  - Menu de navegação principal
  - Notificações
  - Perfil do usuário
  - Botão de logout

### 2.2 Sidebar
- **Menu de Navegação**
  - Dashboard
  - Moderação de Denúncias
  - Moderação do Fórum
  - Moderação de Doações
  - Moderação de Comentários
  - Gestão de Usuários
  - Configurações

### 2.3 Área Principal
- **Cards de Métricas**
  - Denúncias pendentes
  - Doações para análise
  - Usuários aguardando verificação
  - Comentários reportados

- **Gráficos e Estatísticas**
  - Atividades das últimas 24h
  - Distribuição de tipos de denúncia
  - Performance da moderação
  - Taxa de resolução

- **Lista de Atividades Recentes**
  - Timeline de ações
  - Filtros por tipo
  - Status de cada item

## 3. Telas de Moderação

### 3.1 Moderação de Denúncias
- **Lista de Denúncias**
  - Tabela com colunas
    - ID da denúncia
    - Tipo
    - Status
    - Prioridade
    - Data/Hora
    - Denunciante
    - Denunciado
    - Ações
  
  - Filtros
    - Por status
    - Por tipo
    - Por data
    - Por prioridade
  
  - Ordenação por colunas
  - Paginação
  
- **Detalhes da Denúncia**
  - Informações completas
    - Dados da denúncia
    - Conteúdo denunciado
    - Histórico de interações
  
  - Painel de Ações
    - Aprovar
    - Rejeitar
  
  - Campo de observações
  - Log de ações

### 3.2 Moderação do Fórum
- **Visão Geral**
  - Categorias ativas
  - Tópicos recentes
  - Estatísticas

- **Lista de Tópicos**
  - Filtros
    - Por categoria
    - Por data
    - Por status
    - Por palavras-chave
  
  - Tabela de tópicos
    - Título
    - Autor
    - Categoria
    - Data
    - Respostas
    - Visualizações
    - Status
    - Ações

- **Visualização de Tópico**
  - Conteúdo completo
  - Thread de respostas
  - Ferramentas de moderação
    - Editar
    - Excluir
    - Mover
    - Fixar
    - Fechar
  
  - Histórico de moderação

### 3.3 Moderação de Doações
- **Lista de Doações**
  - Filtros
    - Status
    - Categoria
    - Valor
    - Data
  
  - Tabela de doações
    - ID
    - Doador
    - Item/Valor
    - Categoria
    - Status
    - Data
    - Ações

- **Detalhes da Doação**
  - Informações do doador
  - Descrição do item
  - Fotos/Documentos
  - Status atual
  - Histórico
  
  - Painel de Validação
    - Checklist de requisitos
    - Campos de verificação
    - Botões de ação
  
  - Log de alterações

### 3.4 Moderação de Comentários
- **Lista de Comentários**
  - Filtros
    - Por origem
    - Por status
    - Por data
    - Por flags
  
  - Visualização em lista
    - Conteúdo
    - Autor
    - Post original
    - Data
    - Flags
    - Ações

- **Análise de Comentário**
  - Contexto completo
  - Thread relacionada
  - Histórico do usuário
  
  - Ações de moderação
    - Aprovar
    - Rejeitar
    - Editar
    - Excluir
    - Banir usuário

## 4. Gestão de Usuários

### 4.1 Lista de Usuários
- **Tabela Principal**
  - ID
  - Nome
  - Email
  - Status
  - Data de registro
  - Último acesso
  - Ações

- **Filtros Avançados**
  - Status de verificação
  - Nível de acesso
  - Data de registro
  - Histórico de infrações

### 4.2 Perfil do Usuário
- **Informações Básicas**
  - Dados pessoais
  - Foto de perfil
  - Status de verificação
  - Métricas de atividade

- **Histórico**
  - Posts
  - Comentários
  - Doações
  - Denúncias
  - Infrações

- **Ações de Moderação**
  - Verificar perfil
  - Banir usuário
  - Restringir acesso
  - Enviar advertência

## 5. Configurações

### 5.1 Preferências do Sistema
- **Configurações Gerais**
  - Idioma
  - Fuso horário
  - Notificações
  - Tema

- **Regras de Moderação**
  - Palavras proibidas
  - Limites de ação
  - Níveis de gravidade
  - Punições automáticas

### 5.2 Gestão de Moderadores
- **Lista de Moderadores**
  - Informações básicas
  - Estatísticas
  - Atividade recente
  - Performance

- **Configurações de Acesso**
  - Permissões
  - Limites de ação
  - Áreas de atuação

## 6. Elementos Comuns

### 6.1 Sistema de Notificações
- **Painel de Notificações**
  - Lista de notificações
  - Filtros
  - Marcação de lido/não lido
  - Ações rápidas

### 6.2 Barra de Busca Global
- **Componente de Busca**
  - Campo de busca
  - Filtros avançados
  - Resultados em tempo real
  - Histórico de buscas

### 6.3 Feedback do Sistema
- **Mensagens de Sistema**
  - Sucesso
  - Erro
  - Alerta
  - Informação

- **Modais de Confirmação**
  - Título
  - Mensagem
  - Botões de ação
  - Opção de cancelar

### 6.4 Ajuda e Suporte
- **Menu de Ajuda**
  - FAQ
  - Documentação
  - Chat de suporte
  - Tutoriais