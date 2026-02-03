# Clinics-Flow - Railway Deployment

## Services

1. **web** - Next.js Frontend
2. **api** - Node.js Backend API
3. **db** - PostgreSQL Database
4. **ai-router** - AI Router Service (optional)

## Environment Variables

### Database
```
DATABASE_URL=postgresql://user:password@host:5432/clinics_flow
```

### API
```
JWT_SECRET=your-jwt-secret
OPENAI_API_KEY=your-openai-key
NODE_ENV=production
PORT=8080
```

### Frontend
```
NEXT_PUBLIC_API_URL=https://your-api.railway.app
```

### AI Router
```
OLLAMA_URL=http://ollama:11434
OPENAI_API_KEY=your-openai-key
```

## Deployment Steps

### 1. Login to Railway
```bash
railway login
```

### 2. Initialize project
```bash
railway init
```

### 3. Set up services
```bash
# Add PostgreSQL
railway add postgresql

# Add API backend
railway up --service api

# Add frontend
railway up --service web
```

### 4. Set environment variables
```bash
railway variables
```

### 5. Deploy
```bash
railway up
```

## Free Tier Limits

Railway offers $5/month free:
- 1 PostgreSQL database (free tier)
- 1-2 small services (512MB RAM each)
- Limited egress bandwidth

Perfect for MVP/pilot!

## Alternative: Render (Also Free)

If Railway credits run out:
- Web service: Free
- PostgreSQL: Free
- Background jobs: Not free
