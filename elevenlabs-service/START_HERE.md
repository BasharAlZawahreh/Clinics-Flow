# 🚀 Quick Start - ElevenLabs Service

## تثبيت سريع (Quick Install)

```bash
cd /home/bashar/.openclaw/workspace
git clone https://github.com/BasharAlZawahreh/Clinics-Flow.git
cd Clinics-Flow/elevenlabs-service

npm install
npm start
```

## تشغيل (Run)

```bash
# Terminal 1: API
npm start

# Browser: http://localhost:3003
```

## اختبار سريع (Quick Test)

```bash
curl -X POST http://localhost:3003/api/text-to-speech \
  -H "Content-Type: application/json" \
  -d '{"text": "مرحباً بك"}' \
  --output speech.mp3
```

## الدمج مع WhatsApp (WhatsApp Integration)

بمجرد إضافة API call في Clinics-Flow:

```javascript
// في WhatsApp service
async function sendVoiceMessage(phone, text) {
    // Convert text to speech
    const response = await axios.post('http://localhost:3003/api/text-to-speech', {
        text,
        voice_id: 'eleven_multilingual_v2'
    });
    
    // Get audio URL
    const audioUrl = `http://localhost:3003${response.data.url}`;
    
    // Send via WhatsApp Business API
    await sendWhatsAppMessage(phone, null, audioUrl);
}
```

## إضافة ميزات جديدة (New Features)

### محادثة كاملة (Complete Chat)
- حفظ تاريخ المحادثات
- توليد ردود ذكية
- استدعارات الصوت الخاصة بالأطباء

### أصوات مخصصة (Custom Voices)
- استنساخ صوت الطبيب
- أصوات مخصصة لكل عيادة
- تحميل ملفات الصوت الخاصة

### سيناريوهات متعددة (Multi-Scenarios)
- تذكير المواعيد (Voice reminders)
- محادثة مع المرضى (Patient conversations)
- إجابات الأسئلة الشائعة (FAQ auto-replies)

---

**استمتع!** 🎤🇯🇴✨
