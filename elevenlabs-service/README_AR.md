# 🚀 محول النص إلى صوت - ElevenLabs

مشروع كامل لتوليد الأصوات من النص باستخدام ElevenLabs API

## ✨ المميزات

✅ دعم كامل للغة العربية
✅ أصوات متعددة (30+ صوت)
✅ دعم الشخصية المتحدث (Personalized AI voice)
✅ واجهة ويب سهلة الاستخدام
✅ API خدمة قوية (Node.js + Express)
✅ دعم إخراج بصيغات متعددة

## 🚀 التثبيت والتشغيل

### الطريقة 1: Quick Start
```bash
# 1. انسخ المشروع
git clone https://github.com/BasharAlZawahreh/Clinics-Flow.git
cd Clinics-Flow/elevenlabs-service

# 2. تثبيت الاعتماديات
npm install

# 3. إنشاء ملف .env
cp .env.example .env

# 4. تعديل API key
nano .env
# أضف: ELEVENLABS_API_KEY=sk_0ed8b27855c6cf13f844f9c2ab9fdbe259619a09dd8e5501

# 5. تشغيل
npm start
```

### الطريقة 2: تشغيل مباشر (Development)
```bash
# تشغيل مع إعادة التحميل تلقائي
npm run dev
```

## 📊 البنية

```
elevenlabs-service/
├── src/
│   └── server.js          # خادم API
├── web/
│   └── index.html           # واجهة ويب
├── output/                 # ملفات الصوت المولدة
├── README.md                # هذا الملف
├── package.json            # npm dependencies
└── .env.example            # إعدادات المثال
```

## 🔌 Endpoints

### API Service (Port 3003)

| Endpoint | الوصف |
|---------|---------|
| `POST /api/text-to-speech` | تحويل النص إلى صوت |
| `GET /api/voices` | قائمة الأصوات المتاحة |
| `GET /api/health` | فحص حالة الخدمة |
| `GET /api/stats` | إحصائيات الاستخدام |

### Web Interface

- **URL:** `http://localhost:3003` (بعد التشغيل)
- **يدعم:** العربية الإنجليزية
- **مزايا:**
  - نصوص جاهزة (quick templates)
  - إعدادات صوت متقدمة
  - تشغيل مباشر
  - تحميل الصوت
  - نسخ الرابط

## 🎤 نماذج الصوت (الأفضل للعربية)

| الصوت | الوصف | الاستخدام |
|-------|--------|---------|
| **eleven_multilingual_v2** | ⭐ الأفضل للأغلبية العربية | محادثة عادية |
| **eleven_turbo_v2** | ⚡ سريع جدًا | رسائل سريعة |
| **eleven_flash_v2** | 🔥 الأسرع | طلبات فورية |
| **eleven_flash_v2_5** | 🎵 واضح جداً | صوتيات قصيرة |
| **rachel** | 👩 صوت نسائي | كتب، كتب |
| **bella** | 👩 صوت نسائي هادئ | قصص، قصص |
| **domi** | 🧔 صوت ذكوري | ذكاء اصطناعي |
| **antoni** | 🎭 صوت طبيعي ذكي | طبيب، محامي |
| **adam** | 👨 صوت رجولي طبيعي | عائلة، أعمال |
| **charlie** | 👦 صوت طبيعي طبيعي | يويض، أطفال |
| **daniel** | 👨 صوت رجولي | طبيعي | طبيعي |
| **elli** | 😺 صوت شاعر | إعلانات، ترفيه |

## 🇯🇴 دعم اللغة العربية

يدعم:
- ✅ العربية الفصحى (Fusha Arabic)
- ✅ العربية المصرية (Egyptian Arabic)
- ✅ العربية الشامية (Levantine Arabic)
- ✅ الإنجليزية
- ✅ الإسبانية
- ✅ الفرنسية
- ✅ الألمانية

## 💰 الأسعار (حسابات إضافية)

| العدد | الأسعار (مع API key الخاص بك) |
|-------|-----------------------------------|
| 30,000 حرف | ~$30/شهر |
| 100,000 حرف | ~$100/شهر |
| 500,000 حرف | ~$500/شهر |

*ملاحظة: الأسعار تختلف حسب الاشتراك (Free/Pro/Enterprise)*

## 🔧 الإعدادات المتقدمة

### الاستقرار (Stability)
```
0.0 - 0.3 = غير ثابت جدًا (أكثر تعبير)
0.4 - 0.5 = ثابت (موصى)
0.6 - 0.7 = ثابت عالي (أكثر استقرار)
0.8 - 1.0 = غير مستقر (تذبذب)
```

### التشابه (Similarity Boost)
```
0.0 - 0.25 = تقليدي جدًا
0.5 - 0.7 = تقليدي
0.75 - 1.0 = متشابه جدًا (نفس الصوت)
```

### النمط (Style)
```
enhanced = محسن (جودة أعلى)
gentle = ناعم (أكثر نعومة)
neutral = محايد (بدون تعديل)
vibrant = حيوي (طاقة عالية)
```

## 🧪 أمثلة الاستخدام

### مثال 1: تحويل بسيط
```bash
curl -X POST http://localhost:3003/api/text-to-speech \
  -H "Content-Type: application/json" \
  -d '{
    "text": "مرحباً بك"
  }'
```

### مثال 2: تحويل مع إعدادات
```bash
curl -X POST http://localhost:3003/api/text-to-speech \
  -H "Content-Type: application/json" \
  -d '{
    "text": "مرحباً، كيف يمكنني مساعدتك؟",
    "voice_id": "eleven_multilingual_v2",
    "voice_settings": {
      "stability": 0.7,
      "similarity_boost": 0.8,
      "style": "enhanced"
    }
  }'
```

### مثال 3: استخدام Node.js
```javascript
const axios = require('axios');

const response = await axios.post('http://localhost:3003/api/text-to-speech', {
    text: 'مرحباً بك',
    voice_id: 'eleven_multilingual_v2',
    voice_settings: {
        stability: 0.7,
        similarity_boost: 0.8,
        style: 'enhanced'
    }
});

console.log('Audio URL:', response.data.url);
```

## 🔄 التطوير المستقبلي

### المميزات القادمة
- [ ] محادثة حوار كاملة (Chatbot)
- [ ] تخصيص الصوت حسب المريض
- [ ] دمج مع WhatsApp API
- [ ] إضافة SFX (مؤثرات صوتية)
- [ ] حفظ السجل الصوتي
- [ ] تحويل الميكروفونات (WAV)
- [ ] تحويل الفيديو

### الدمج مع Clinics-Flow
يمكن دمج هذه الخدمة مع نظام إدارة العيادات:

1. ✅ رسائل صوتية للمواعيد
2. ✅ تذكيرات صوتية للمرضى
3. ✅ محادثة صوتية مع المرضى
4. ✅ توليد ملفات صوتية للتقارير

## 📞 المساعدة والدعم

### الأسئلة الشائعة

**سؤال:** لا يعمل التحويل؟
**جواب:** تأكد من API key صحيح في .env

**سؤال:** الصوت لا جيد؟
**جواب:** جرب صوت آخر (eleven_multilingual_v2) أو ارفع الاستقرار

**سؤال:** كيف أدمج مع WhatsApp؟
**جواب:** استخدم API /api/text-to-speech ثم أرسل الملف عبر WhatsApp Business API

**سؤال:** كيف أعمل محادثة كاملة؟
**جواب:** أضف endpoint جديد في server.js للحفاظ على المحادثة وإنشاء ردود ذكية

## 🎯 الخاتمة

هذه خدمة قوية وقابلة للتطوير. البدء باستخدام:

```bash
npm install
npm start
```

ثم افتح المتصفح على: `http://localhost:3003`

**استمتع!** 🎤✨🇯🇴
