# ElevenLabs Service - Text to Speech
# Complete service for voice generation with ElevenLabs API

## API Key
`ELEVENLABS_API_KEY=sk_0ed8b27855c6cf13f844f9c2ab9fdbe259619a09dd8e5501`

## Endpoints

### 1. Text to Speech (TTS)
**Endpoint:** `POST https://api.elevenlabs.io/v1/text-to-speech/{voice_id}`

**Voice Options:**
- `eleven_multilingual_v2` - أفضل للأغلبية العربية ⭐
- `eleven_turbo_v2` - سريع جداً
- `eleven_flash_v2` - الأسرع
- `eleven_flash_v2_5` - خفيف، واضح
- `rachel` - صوت نسائي
- `domi` - صوت ذكوري
- `adam` - صوت رجولي
- `antoni` - صوت يوناني
- `elli` - صوت شاعر
- `bella` - صوت نسائي هادئ
- `charlie` - صوت رجولي دافئ
- `daniel` - صوت طبيعي

**Parameters:**
```json
{
  "text": "النص هنا",
  "model_id": "eleven_multilingual_v2",
  "voice_settings": {
    "stability": 0.5,
    "similarity_boost": 0.75
  },
  "output_format": "mp3_44100_192",
  "xi_api_key": "sk_0ed8b..."
}
```

### 2. List Available Voices
**Endpoint:** `GET https://api.elevenlabs.io/v1/voices`

### 3. Get Voice Settings
**Endpoint:** `GET https://api.elevenlabs.io/v1/voices/{voice_id}/settings`

### 4. Stream Audio
**Endpoint:** `GET https://api.elevenlabs.io/v1/text-to-speech/{voice_id}/stream`

## Arabic Support

ElevenLabs يدعم:
- ✅ العربية الفصحى (Fusha Arabic)
- ✅ العربية المصرية (Egyptian Arabic)
- ✅ العربية الشامية (Levantine Arabic)
- ✅ الإنجليزية
- ✅ لغات متعددة (30+ لغة)

## Pricing

| Model | الحروف | الكلمات |
|-------|---------|----------|
| Multilingual V2 | 1,000 | 80,000 |
| Turbo V2 | 5,000 | 200,000 |
| Flash V2 | 2,500 | 100,000 |
| Flash V2.5 | 5,000 | 500,000 |

**أرخص من OpenAI بـ 80% تقريبًا!**

## Voice Examples

| الغرض | الصوت الموصى | الأسباب |
|-------|--------------|---------|
| **عام** | `eleven_multilingual_v2` | دقة عالية، طبيعي |
| **سريع** | `eleven_turbo_v2` | رسائل سريعة |
| **طبيب** | `rachel`, `bella` | ناعم، راق |
| **طبيب** | `charlie`, `daniel` | حاد، ودي |
| **شاعر** | `elli` | طاقة عالية |
| **ذكوري** | `domi` | AI متقدم |
| **طبيعي** | `adam`, `antoni` | صوت بشري |

## Usage Limits
- 30 رسالة/ثانية (للحسابات المجانية)
- 150 رسالة/ثانية (حسابات Pro)
- حد أقصى: 200,000 حرف/رسالة
