# 🚀 جاهز للاستخدام! - دليل العمل مع خدمة ElevenLabs

## 📋 **الخطوات السريعة**

### 1. تشغيل خدمة API
```bash
cd /home/bashar/.openclaw/workspace/Clinics-Flow/elevenlabs-service
./workflow.sh start
```

### 2. تحويل النص إلى صوت
```bash
./workflow.sh convert "مرحباً بك"
```

### 3. اختبار الخدمة
```bash
./workflow.sh test
```

### 4. إيقاف الخدمة
```bash
./workflow.sh stop
```

### 5. عرض الحالة
```bash
./workflow.sh status
```

### 6. عرض السجلات
```bash
./workflow.sh logs
```

### 7. فحص الصحة
```bash
./workflow.sh health
```

## 🔧 **إعدادات**

### ملف البيئة (.env)
```bash
ELEVENLABS_API_KEY=sk_0ed8b27855c6cf13f844f9c2ab9fdbe259619a09dd8e5501
```

### الحصول على API Key
1. افتح: https://elevenlabs.io/app
2. سجل دخولك
3. إنشاء New API Key
4. أنسخ API Key
5. أضف في .env

## 📁 **هيكلية الملفات**

```
elevenlabs-service/
├── src/
│   └── server.js              # خادم API
├── web/
│   └── index.html           # واجهة ويب
├── workflow.sh               # سكريبت الدورة
├── README.md                # الدليل (إنجليزي)
└── .env.example              # إعدادات مثال
```

## 🎯 **أمر سريع للتحويل**

```bash
curl -X POST http://localhost:3003/api/text-to-speech \
  -H "Content-Type: application/json" \
  -d '{"text": "مرحباً بك"}'
```

## 📱 **الواجهة ويب**

افتح المتصفح على:
```
http://localhost:3003
```

## 🎤 **مستندات API**

### POST /api/text-to-speech
تحويل النص إلى صوت

**Body:**
```json
{
  "text": "النص هنا",
  "voice_id": "eleven_multilingual_v2",
  "stability": 0.5,
  "similarity_boost": 0.75,
  "style": "enhanced"
}
```

**Response:**
```json
{
  "success": true,
  "filename": "speech_1234567890.mp3",
  "url": "/output/speech_1234567890.mp3",
  "duration": 5000
  "size": 150000
  "voice_settings": {...}
}
```

### GET /api/voices
قائمة الأصوات المتاحة

### GET /api/health
فحص حالة الخدمة

## 🌐 **دمج مع WhatsApp**

### خيار 1: إرسال الملف الصوتي عبر WhatsApp Business API

### خيار 2: تحويل مباشر للإرسال عبر WhatsApp
```bash
curl -X POST http://localhost:3003/api/text-to-speech \
  -H "Content-Type: application/json" \
  -d '{"text": "مرحباً بك"}' \
  --output voice.mp3

# ثم إرسال voice.mp3 عبر WhatsApp
```

## 🔊 **القيود والمساحة**

| الخيار | القيود | السعر |
|--------|---------|----------|
| حساب Free | 30,000 حرف/شهر | $0 |
| حساب Starter | 100,000 حرف/شهر | $20 |
| حساب Pro | 500,000 حرف/شهر | $80 |

## ⚠️ **تنبيهات مهمة**

- ✅ **لا تشارك API Key** مع أحد
- ✅ **استخدم حساب خاص** لتطوير
- ✅ **راقب الاستخدام** من لوحة ElevenLabs
- ✅ **احفظ ملفات الصوت** محليًا

## 🚀 **ابدأ الآن!**

```bash
./workflow.sh start
```

ثم افتح:
```
http://localhost:3003
```

**ممارس آمن:** استخدم فقط للتطوير، ليس للإنتاج النهائي!
