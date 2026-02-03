# Ollama AI Router - Technical Deep Dive
## Architecture, Decision Logic & Infrastructure Guide

---

## 1️⃣ كيف يتخذ AI Router القرار؟ (Decision Engine)

### المنطق البرمجي (Code Logic)

```typescript
function shouldUseOllama(request: AIRequest): boolean {
  // ✅ استخدم Ollama إذا:
  
  // 1. المهمة بسيطة ولا تحتاج إبداع
  if (request.complexity === 'low' && !request.requiresCreativity) 
    return true;
  
  // 2. النص قصير وبالإنجليزية
  if (request.content.length < 500 && request.language === 'en') 
    return true;
  
  // 3. مهام محددة (تصنيف، استخراج، مشاعر بسيط)
  if (['classification', 'extraction', 'sentiment_simple'].includes(request.task)) 
    return true;
  
  // 4. توليد قوالب
  if (request.task === 'template_generation') 
    return true;
  
  // ❌ استخدم OpenAI إذا:
  
  // 1. المهمة معقدة
  if (request.complexity === 'high') 
    return false;
  
  // 2. يحتاج إبداع بالعربية
  if (request.requiresCreativity && request.language === 'ar') 
    return false;
  
  // 3. تحليل معمق
  if (request.task === 'complex_analysis') 
    return false;
  
  // الافتراضي: Ollama للتوفير
  return true;
}
```

### أمثلة عملية:

| الطلب | القرار | السبب |
|-------|--------|-------|
| "حجز موعد غداً" | ✅ Ollama | بسيط، قالب |
| "تحليل شكوى معقدة" | ❌ OpenAI | يحتاج فهم عميق |
| "تصنيف: حجز/إلغاء" | ✅ Ollama | classification بسيط |
| "توليد محتوى تسويقي" | ❌ OpenAI | إبداع + عربي |
| "مشاعر: رائع/سيئ" | ✅ Ollama | binary sentiment |

---

## 2️⃣ Docker Setup - هل Ollama مثبت مسبقاً؟

### الإجابة: لا، لكننا نثبته لك تلقائياً!

### الخيار A: Docker Compose الكامل (الأسهل)

```yaml
# docker-compose.ollama.yml
version: '3.8'

services:
  ollama:
    image: ollama/ollama:latest
    container_name: ollama
    volumes:
      - ollama_data:/root/.ollama  # ← النماذج هنا
    ports:
      - "11434:11434"
    # سيقوم بتنزيل النماذج تلقائياً
    
  ai-router:
    build: ./ai-router
    environment:
      - OLLAMA_URL=http://ollama:11434  # ← اتصال داخلي
```

**ما يحدث:**
1. 🐳 Docker ينزل صورة Ollama جاهزة
2. 📥 عند أول استخدام، ينزل النموذج (Qwen 7B = 4GB)
3. 💾 النموذج يُحفظ في volume (لا يحتاج تنزيل مرة أخرى)
4. ⚡ يبقى محملاً في الذاكرة للسرعة

### الخيار B: تثبيت يدوي (للتطوير)

```bash
# على جهازك المحلي (بدون Docker)
curl -fsSL https://ollama.com/install.sh | sh
ollama pull qwen2.5:7b
ollama serve  # ← يعمل على localhost:11434
```

**للتطوير المحلي، للإنتاج استخدم Docker.**

---

## 3️⃣ Dockerizing كل المشروع 🐳

### docker-compose.complete.yml

```yaml
version: '3.8'

services:
  # ==========================================
  # 1. DATABASE Layer
  # ==========================================
  postgres:
    image: postgres:15-alpine
    container_name: clinics-postgres
    environment:
      POSTGRES_USER: ${DB_USER:-joclinics}
      POSTGRES_PASSWORD: ${DB_PASSWORD:-secret}
      POSTGRES_DB: ${DB_NAME:-joclinicsflows}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER}"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    container_name: clinics-redis
    volumes:
      - redis_data:/data
    ports:
      - "6379:6379"

  # ==========================================
  # 2. AI Layer (Ollama + Router)
  # ==========================================
  ollama:
    image: ollama/ollama:latest
    container_name: clinics-ollama
    volumes:
      - ollama_data:/root/.ollama
    ports:
      - "11434:11434"
    environment:
      - OLLAMA_NUM_PARALLEL=4
      - OLLAMA_MAX_LOADED_MODELS=2
    # للـ GPU (اختياري):
    # deploy:
    #   resources:
    #     reservations:
    #       devices:
    #         - driver: nvidia
    #           count: 1
    #           capabilities: [gpu]

  ai-router:
    build:
      context: ./ai-router
      dockerfile: Dockerfile
    container_name: clinics-ai-router
    environment:
      - NODE_ENV=production
      - PORT=3000
      - OLLAMA_URL=http://ollama:11434
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - REDIS_URL=redis://redis:6379
    depends_on:
      - ollama
      - redis
    ports:
      - "3006:3000"

  # ==========================================
  # 3. BACKEND API
  # ==========================================
  api:
    build:
      context: ./apps/api
      dockerfile: Dockerfile
    container_name: clinics-api
    environment:
      - NODE_ENV=production
      - PORT=3001
      - DATABASE_URL=postgresql://${DB_USER}:${DB_PASSWORD}@postgres:5432/${DB_NAME}
      - REDIS_URL=redis://redis:6379
      - OLLAMA_URL=http://ollama:11434
      - AI_ROUTER_URL=http://ai-router:3000
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - JWT_SECRET=${JWT_SECRET}
      - WHATSAPP_ACCESS_TOKEN=${WHATSAPP_ACCESS_TOKEN}
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_started
      ai-router:
        condition: service_started
    ports:
      - "3001:3001"
    volumes:
      - api_logs:/app/logs

  # ==========================================
  # 4. FRONTEND
  # ==========================================
  web:
    build:
      context: ./apps/web
      dockerfile: Dockerfile
    container_name: clinics-web
    environment:
      - NEXT_PUBLIC_API_URL=http://api:3001
      - NODE_ENV=production
    depends_on:
      - api
    ports:
      - "3000:3000"

  # ==========================================
  # 5. REVERSE PROXY (Nginx)
  # ==========================================
  nginx:
    image: nginx:alpine
    container_name: clinics-nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/ssl:/etc/nginx/ssl:ro
    depends_on:
      - web
      - api

volumes:
  postgres_data:
  redis_data:
  ollama_data:
  api_logs:

networks:
  default:
    name: clinics-network
```

### Dockerfile للـ Backend:

```dockerfile
# apps/api/Dockerfile
FROM node:20-alpine

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci --only=production

# Copy prisma schema
COPY packages/database/prisma ./prisma/
RUN npx prisma generate

# Copy built application
COPY dist ./dist

# Health check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD curl -f http://localhost:3001/health || exit 1

EXPOSE 3001

CMD ["node", "dist/index.js"]
```

### Dockerfile للـ Frontend:

```dockerfile
# apps/web/Dockerfile
FROM node:20-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production

COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static

EXPOSE 3000

CMD ["node", "server.js"]
```

---

## 4️⃣ تكاليف المعالجة والبنية التحتية 💰

### سيناريو 1: البداية (CPU فقط)

**المواصفات:**
```
CPU: 4 cores
RAM: 16 GB
Storage: 100 GB SSD
GPU: None (CPU only)
```

**التكلفة الشهرية:**
| المكون | المواصفات | التكلفة |
|--------|-----------|---------|
| VPS | DigitalOcean 4GB/2CPU | $24 |
| أو Hetzner | CPX21 (4 vCPU/8GB) | €12 ($13) |
| التخزين | 100GB | $10 |
| **المجموع** | | **$23-34** |

**الأداء المتوقع:**
- Qwen 7B على CPU: 5-10 tokens/second
- مناسب لـ < 1,000 request/يوم
- latency: 2-5 seconds

---

### سيناريو 2: النمو (GPU أساسي)

**المواصفات:**
```
GPU: NVIDIA T4 (16GB VRAM)
CPU: 8 cores
RAM: 32 GB
Storage: 200 GB SSD
```

**التكلفة الشهرية:**
| المزود | المواصفات | التكلفة |
|--------|-----------|---------|
| Google Cloud | T4 + n1-standard-4 | $200 |
| AWS | g4dn.xlarge | $185 |
| RunPod | RTX 3090 Community | $100 |
| **المجموع** | | **$100-200** |

**الأداء المتوقع:**
- Qwen 14B على GPU: 30-50 tokens/second
- مناسب لـ < 10,000 request/يوم
- latency: 200-500ms

---

### سيناريو 3: التوسع (GPU متوسط)

**المواصفات:**
```
GPU: NVIDIA A10 (24GB VRAM)
CPU: 16 cores
RAM: 64 GB
Storage: 500 GB SSD
```

**التكلفة الشهرية:**
| المزود | المواصفات | التكلفة |
|--------|-----------|---------|
| AWS | g5.xlarge (A10) | $400 |
| Google Cloud | a2-highgpu-1g | $450 |
| **المجموع** | | **$400-500** |

**الأداء المتوقع:**
- Qwen 32B على GPU: 20-30 tokens/second
- مناسب لـ < 50,000 request/يوم
- يدعم نماذج أكبر وأدق

---

## 5️⃣ مقارنة التكاليف: Cloud vs Hybrid

### بدون Ollama (OpenAI فقط):
```
10,000 request/month × $0.002 = $20
+ API Backend: $20
+ Database: $15
+ Frontend: $10
= $65/month
```

### مع Hybrid (Ollama + OpenAI):
```
7,000 request (Ollama) × $0 = $0
3,000 request (OpenAI) × $0.002 = $6
+ VPS (4CPU/16GB): $25
+ Database: $0 (نفس الخادم)
+ AI Router: $0 (نفس الخادم)
= $31/month
```

### **التوفير: $34/month (52%)** 💰

---

## 6️⃣ Scaling Strategy (استراتيجية التوسع)

### المرحلة 1: 0-1000 request/يوم
```
→ CPU only (Qwen 7B)
→ DigitalOcean $24/month
→ Vertical scaling (زيادة RAM)
```

### المرحلة 2: 1000-5000 request/يوم
```
→ GPU entry-level (T4)
→ RunPod $100/month
→ Horizontal scaling (Load balancer)
→ Redis cluster
```

### المرحلة 3: 5000-20000 request/يوم
```
→ GPU mid-range (A10)
→ Multiple Ollama instances
→ Database separate server
→ CDN for static files
```

### المرحلة 4: 20000+ request/يوم
```
→ Kubernetes cluster
→ Auto-scaling
→ Multi-region
→ Dedicated AI cluster
```

---

## 7️⃣ خطوات التنفيذ العملي

### الخطوة 1: إعداد البيئة
```bash
# 1. انسخ ملف البيئة
cp .env.example .env

# 2. عدل المتغيرات
nano .env
# أضف OPENAI_API_KEY وغيره

# 3. شغل كل شيء
docker-compose -f docker-compose.complete.yml up -d

# 4. تحقق من الخدمات
curl http://localhost:3001/health
curl http://localhost:3006/health
curl http://localhost:11434/api/tags
```

### الخطوة 2: تنزيل النماذج
```bash
# انتظر دقيقتين حتى Ollama يجهز
sleep 30

# نزل النماذج
docker-compose exec ollama ollama pull qwen2.5:7b
docker-compose exec ollama ollama pull mistral:7b

# تحقق
docker-compose exec ollama ollama list
```

### الخطوة 3: اختبار
```bash
# اختبار Ollama
curl -X POST http://localhost:3006/generate \
  -H 'Content-Type: application/json' \
  -d '{
    "task": "sentiment_analysis",
    "content": "Great service!",
    "language": "en"
  }'

# اختبار OpenAI
curl -X POST http://localhost:3006/generate \
  -H 'Content-Type: application/json' \
  -d '{
    "task": "complex_analysis",
    "content": "Analyze patient feedback...",
    "complexity": "high",
    "language": "ar"
  }'
```

---

## 8️⃣ Monitoring & Alerts

### Prometheus + Grafana (مجاني)

```yaml
# إضافة إلى docker-compose
prometheus:
  image: prom/prometheus
  volumes:
    - ./prometheus.yml:/etc/prometheus/prometheus.yml
  ports:
    - "9090:9090"

grafana:
  image: grafana/grafana
  ports:
    - "3007:3000"
  volumes:
    - grafana_data:/var/lib/grafana
```

### المقاييس المهمة:
- **Ollama latency** (يجب أن يكون < 3s)
- **OpenAI cost** (يومي/أسبوعي)
- **Request distribution** (نسبة Ollama vs OpenAI)
- **GPU utilization** (إن وجد)
- **Error rate** (يجب أن يكون < 1%)

---

## 9️⃣ Troubleshooting Guide

### المشكلة 1: Ollama بطيء جداً
```bash
# السبب: CPU غير كافي أو النموذج كبير
# الحل: استخدم نموذج أصغر
ollama pull qwen2.5:4b  # بدلاً من 7b

# أو استخدم quantization
ollama pull qwen2.5:7b-q4_0  # أقل دقة، أسرع
```

### المشكلة 2: الذاكرة تنفد
```bash
# السبب: نماذج كثيرة محملة
# الحل: احتفظ بنموذج واحد فقط
export OLLAMA_MAX_LOADED_MODELS=1

# أو زود RAM
# DigitalOcean: upgrade to 8GB RAM
```

### المشكلة 3: Fallback لا يعمل
```bash
# السبب: OpenAI API key غير موجود
# الحل: تأكد من .env
docker-compose exec ai-router env | grep OPENAI

# إذا فارغ:
docker-compose down
docker-compose up -d
```

---

## 🎯 الخلاصة

| السؤال | الجواب |
|--------|--------|
| كيف يقرر؟ | بناءً على complexity + language + creativity |
| هل يحتاج تثبيت مسبق؟ | لا، Docker يثبته تلقائياً |
| Docker كامل؟ | نعم، كل المشروع في docker-compose |
| تكلفة المعالجة؟ | $23-500 حسب المرحلة |
| التوفير؟ | 52% مقارنة بـ OpenAI فقط |

**التوصية:** ابدأ بـ CPU ($24/شهر)، وانتقل لـ GPU عندما تتجاوز 1000 request/يوم.

**هل تريد أن أبدأ بإعداد Docker Compose الكامل؟** 🐳
