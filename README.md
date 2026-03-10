# 🛡️ CyberShield Brasil

SaaS de cibersegurança para detectar phishing, malware, golpes e PIX suspeitos.

## 🚀 Setup Rápido

### 1. Instalar dependências
```bash
npm install
```

### 2. Configurar variáveis de ambiente
Copie `.env.local` e preencha com suas chaves reais.

### 3. Configurar Supabase
- Abra o SQL Editor no Supabase
- Cole e execute o conteúdo de `SUPABASE_SETUP.sql`

### 4. Rodar localmente
```bash
npm run dev
```

### 5. Deploy no Vercel
- Conecte o repositório ao Vercel
- Adicione todas as variáveis de ambiente
- Deploy automático!

## 📋 Variáveis de Ambiente

| Variável | Descrição |
|----------|-----------|
| NEXT_PUBLIC_SUPABASE_URL | URL do seu projeto Supabase |
| NEXT_PUBLIC_SUPABASE_ANON_KEY | Chave anônima do Supabase |
| SUPABASE_SERVICE_ROLE_KEY | Chave de serviço do Supabase |
| VIRUSTOTAL_API_KEY | Chave da VirusTotal API |
| STRIPE_SECRET_KEY | Chave secreta do Stripe |
| STRIPE_WEBHOOK_SECRET | Secret do webhook do Stripe |
| STRIPE_PRICE_BASE | Price ID do plano Base |
| STRIPE_PRICE_PLUS | Price ID do plano Plus |
| STRIPE_PRICE_DEV | Price ID do plano Developer |
| OPENAI_API_KEY | Chave da OpenAI (explicações IA) |

## 🏗️ Stack
- Next.js 14 + TypeScript
- Supabase (Auth + PostgreSQL)
- Stripe (pagamentos)
- VirusTotal API
- OpenAI GPT-4o-mini
