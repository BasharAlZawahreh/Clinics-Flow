# Clinics-Flow - Render Free Deployment

Render offers better free tier for full-stack apps.

## Services to Deploy

1. **Web Service (Frontend)** - Next.js
2. **Web Service (API)** - Node.js backend  
3. **PostgreSQL** - Database
4. **Redis** - For caching (optional)

## Deployment Steps

### 1. Prepare Project
```bash
cd Clinics-Flow

# Create production-ready package.json adjustments
```

### 2. Connect GitHub to Render
1. Go to https://dashboard.render.com
2. Click "New +" → "Web Service"
3. Connect your GitHub repo: `BasharAlZawahreh/Clinics-Flow`
4. Select branch: `main`

### 3. Configure Frontend (Web Service 1)
```
Root Directory: apps/web
Build Command: npm run build
Start Command: npm start
Environment Variables:
  - NEXT_PUBLIC_API_URL=https://your-api.onrender.com
  - NODE_ENV=production
Instance Type: Free
```

### 4. Configure Backend (Web Service 2)
```
Root Directory: apps/api
Build Command: npm install
Start Command: npm run start:prod
Environment Variables:
  - DATABASE_URL=postgresql://...
  - JWT_SECRET=your-secret
  - OPENAI_API_KEY=your-key
  - PORT=8080
  - NODE_ENV=production
Instance Type: Free
```

### 5. Add PostgreSQL
```
Database: PostgreSQL
Name: clinics-flow-db
Database: clinics_flow
User: clinics_flow_user
Region: Oregon (cheaper)
Plan: Free
```

### 6. Get Database URL
After creating PostgreSQL, click "External Database URL"
Copy the URL and add it to backend env vars.

## Free Tier Limits

Render Free Plan:
✅ 1 PostgreSQL database (90 days inactivity limit)
✅ 1-2 Web Services (free tier)
✅ 512MB RAM per service
✅ Auto-deploy from git push
✅ SSL certificates included

❌ Background workers not free
❌ No custom domains on free tier

## Alternative: Railway

Railway offers $5 free monthly credit:
- Better free tier for multiple services
- Includes background services
- Simple configuration
- But credits renew monthly

## Choose Based on Needs

**Choose Render if:**
- Long-term free hosting needed
- Stable free tier (no credits to expire)
- OK with some limitations

**Choose Railway if:**
- Need multiple services
- Background services required
- OK with $5 monthly credit system
