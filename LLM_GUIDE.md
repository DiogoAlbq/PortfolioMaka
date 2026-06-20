# Arquitetura do Projeto e Guia para LLMs

Este documento foi criado para ajudar outra LLM a mapear o projeto atual, entender como ele funciona, e orientar sobre como remover dependências ou restrições injetadas unicamente para a execução no ambiente do Google AI Studio.

## 1. Visão Geral do Frontend
O frontend é uma Single Page Application (SPA) responsiva focado no portfólio de arte e sistema de comissões/orçamentos.
- **Tecnologias Base**: React 18+, Vite, Tailwind CSS v4+.
- **Animações e Ícones**: Usa `motion/react` (Framer Motion) para as transições de scroll/layout e `lucide-react` para os SVGs.
- **Estrutura de Código**:
  - `src/App.tsx`: É o "cérebro" das interfaces. Ele contém abas de visualização, troca de temas (Light/Dark), sistema de idiomas (PT/EN), tabs de portfolio e a lógica de geração do texto de orçamento (que é copiado para o clipboard com dados dinâmicos).
  - `src/data.tsx`: Onde residem os dados e dicionários. Aqui estão guardados os itens da tabela de "Investimento" (`pricingData`), os textos multilingues e os dados estáticos do portfólio (`artItems`, `videoItems`). Tudo está desacoplado em um lugar só para facilitar atualizações.
  - `src/index.css`: Contém a inicialização do Tailwind (`@import "tailwindcss";`) e a sobrescrita global para o **cursor personalizado** (que aponta para `/cursor.png` na pasta `public/`).

## 2. Visão Geral do Backend
Como o Google AI Studio opera projetos full-stack padronizados no Docker, o projeto utiliza um backend Express acoplado com o Vite.
- **Arquivo Principal**: `server.ts`
- **Comportamento**: Ele sobe uma API mínima (como o `GET /api/health`) e atua como middleware de servidor para o SSR/Vite.
- **Build**: No `package.json`, o script de build transpila esse servidor inteiro via `esbuild` para jogar o resultado empacotado em `dist/server.cjs`.

---

## 3. Guia de Migração para GitHub e Deploy na Vercel

O Google AI Studio obriga algumas amarras e arquivos de configuração para o seu preview online funcionar corretamente. Como o objetivo é hospedar este projeto gratuitamente na **Vercel** via integração com **GitHub** (sendo um site puramente estático/Client-Side), a próxima LLM deve aplicar os passos abaixo nas pastas do repositório antes do deploy.

### Passo 1: Remover as "Sujeiras" do AI Studio
Estes arquivos não são úteis para a Vercel e tratam-se apenas de metadados do Google AI Studio:
1. Deletar o arquivo **`metadata.json`** da pasta raiz.
2. Deletar a pasta inteira **`assets/`** ou `assets/.aistudio` (se for exportada para o GitHub).

### Passo 2: Remover o Backend Express
O ambiente do AI Studio cria um servidor customizado (`server.ts`) para servir a aplicação. Como a Vercel já lida com SPAs nativamente rápido e de graça, você deve remover esse servidor Express:
1. **Delete o arquivo `server.ts`** da raiz do projeto.
2. Opcionalmente, pode executar: `npm uninstall express esbuild tsx @types/express`

### Passo 3: Limpar os Scripts no `package.json`
Com o backend removido, a aplicação volta a ser um projeto Vite React comum. Altere a sessão `"scripts"` dentro de `package.json` substituindo tudo por:
```json
  "scripts": {
    "dev": "vite",
    "build": "tsc -b && vite build",
    "lint": "eslint .",
    "preview": "vite preview"
  }
```

### Passo 4: Configurar o Deploy na Vercel (Routing SPA)
Ao hospedar um projeto React (Vite) na Vercel, caso hajam rotas, elas podem retornar erro 404 ao atualizar a página (se houverem React Router, por exemplo).
Para garantir a performance, crie na raiz do projeto final (junto do package.json) o arquivo \`vercel.json\` com o seguinte código, informando a Vercel para rotear tudo ao \`index.html\`:
```json
{
  "rewrites": [
    {
      "source": "/(.*)",
      "destination": "/index.html"
    }
  ]
}
```

Feito isso, o projeto está 100% otimizado, sem o "garbage" do AI Studio, sem consumo inútil de servidor backend-node e pronto para o deploy grátis na Vercel!
