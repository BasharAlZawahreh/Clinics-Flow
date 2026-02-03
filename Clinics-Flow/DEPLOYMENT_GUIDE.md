# ✅ Clinics-Flow Deployment to Render

## Deployment Status: **FIXED** ✅

All build issues resolved:
- ✅ TypeScript moved to dependencies
- ✅ Hardcoded localhost removed
- ✅ Standalone mode disabled
- ✅ Builds verified locally

---

## 🚀 Quick Deploy (One-Click)

1. **Click this link:**
   https://render.com/deploy?repo=https://github.com/BasharAlZawahreh/Clinics-Flow

2. **Connect GitHub** → Select repository

3. **Use render.yaml blueprint** (auto-config)

4. **Wait 5-10 minutes** for deployment

---

## 📋 Required Environment Variables

### Step 1: Add to API Service

In Render → clinics-flow-api → Environment:

```bash
JWT_SECRET=271637a13aad7abbffa1d43b7fb8dca9d2ada445f5044b43ae2ae624ce5b41ac

# Get from PostgreSQL service (click "External Database URL")
DATABASE_URL=postgresql://...

# Your OpenAI API key from .env
OPENAI_API_KEY=sk-proj-...

PORT=8080
NODE_ENV=production
```

### Step 2: Add to Web Service

In Render → clinics-flow-web → Environment:

```bash
# Update this AFTER API deploys
NEXT_PUBLIC_API_URL=https://clinics-flow-api.onrender.com/v1

NODE_ENV=production
```

---

## 🔧 Order of Operations

### 1. Deploy PostgreSQL
```
Create: clinics-flow-db
Region: Oregon (or nearest)
Plan: Free
→ Wait for "Live" status
→ Copy "External Database URL"
```

### 2. Deploy API
```
Create: clinics-flow-api
Root: apps/api
Build: npm install && npm run build
Start: npm start
Env: Add DATABASE_URL, JWT_SECRET, OPENAI_API_KEY
→ Wait for "Live" status
→ Copy URL: https://clinics-flow-api.onrender.com
```

### 3. Deploy Web
```
Create: clinics-flow-web
Root: apps/web
Build: npm install && npm run build
Start: npm start
Env: Add NEXT_PUBLIC_API_URL (from step 2)
→ Wait for "Live" status
```

---

## 🌐 Your URLs

| Service | URL |
|---------|-----|
| Frontend | https://clinics-flow-web.onrender.com |
| API | https://clinics-flow-api.onrender.com |
| Dashboard | https://dashboard.render.com |

---

## ⚠️ Important Notes

### Free Tier Limitations
- **Cold Start:** ~30 seconds first load
- **Auto-Sleep:** After 15 min inactivity
- **Database:** Stays active (no sleep)
- **Domain:** onrender.com subdomain only

### Production Upgrade (Recommended)
If you go live with customers, upgrade to:
- **Starter Plan ($7/mo)**
  - No cold starts
  - Custom domain
  - More CPU/RAM
  - Better performance

---

## 🐛 Troubleshooting

### Build Fails: "MODULE_NOT_FOUND"
**Solution:** Already fixed - TypeScript in dependencies ✅

### Build Fails: "Failed to transpile next.config.ts"
**Solution:** Already fixed - localhost removed ✅

### API Returns 404/502
**Check:**
1. API service is "Live" in Render
2. DATABASE_URL is correct
3. PORT is set to 8080

### Frontend Can't Connect to API
**Check:**
1. NEXT_PUBLIC_API_URL is set correctly
2. API URL ends with `/v1`
3. Both services are "Live"

### Database Connection Error
**Check:**
1. DATABASE_URL format is correct
2. Database service is "Live"
3. URL is from "External Database URL"

---

## 🔄 Auto-Deploy on Git Push

When you push to GitHub main branch:
```
git add .
git commit -m "update"
git push origin main
```

Render automatically:
- Detects new commit
- Rebuilds changed services
- Deploys live
- No manual action needed

---

## 📊 Monitoring

View logs in Render Dashboard:
- **Web Service:** Frontend errors
- **API Service:** Backend errors, API calls
- **Database:** Connection logs

---

## ✅ Deployment Checklist

Before going live:
- [ ] All 3 services deployed (web, api, db)
- [ ] Environment variables set correctly
- [ ] Test login works
- [ ] Test appointment booking
- [ ] Test dashboard loads
- [ ] API calls from frontend work
- [ ] Database saves data
- [ ] SSL certificate active (automatic on Render)

---

## 📞 Need Help?

Check Render's troubleshooting guide:
https://render.com/docs/troubleshooting-deploys

Or share the error log with me!
