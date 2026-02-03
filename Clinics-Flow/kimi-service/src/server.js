const express = require('express');
const cors = require('cors');
const axios = require('axios');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3004;

// Kimi API Configuration
// Get your API key from: https://kimi.moonshot.cn/
const KIMI_API_KEY = process.env.KIMI_API_KEY || '';

// Default model: Kimi 2.5 (128K context, excellent Arabic)
const KIMI_MODEL = 'kimi-2.5';

app.use(cors());
app.use(express.json());

// ========================
// Health Check
// ========================

app.get('/api/health', (req, res) => {
    res.json({
        status: 'ok',
        service: 'Kimi AI (Moonshot)',
        model: KIMI_MODEL,
        arabic_support: true,
        context_size: '128K',
        free_plan: true,
        timestamp: new Date().toISOString()
    });
});

// ========================
// Chat Completions (Main AI)
// ========================

/**
 * Send text completion request to Kimi API
 * Supports Arabic, Chinese, English, and 30+ languages
 */
app.post('/api/chat', async (req, res) => {
    try {
        const { text, system_prompt, temperature = 0.7 } = req.body;

        if (!text || text.trim() === '') {
            return res.status(400).json({
                success: false,
                error: 'Text is required'
            });
        }

        console.log(`🎤 Processing: ${text.substring(0, 50)}...`);

        const response = await axios.post(
            'https://api.moonshot.cn/v1/chat/completions',
            {
                model: KIMI_MODEL,
                messages: [
                    {
                        role: 'system',
                        content: system_prompt || 'أنت مساعد ذكي متخصص في المجال الطبي. تتفاعل بلغة العربية الفصحى المصرية. أجب بدقة، احترافي، وبأسلوب مناسبة.'
                    },
                    {
                        role: 'user',
                        content: text
                    }
                ],
                temperature: temperature
            },
            {
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${KIMI_API_KEY}`
                },
                maxBodyLength: 10485760, // 100MB
                timeout: 30000 // 30 seconds
            }
        );

        const result = response.data;

        console.log(`✅ Response received`);
        console.log(`   Tokens: ${result.usage?.total_tokens || 'N/A'}`);

        res.json({
            success: true,
            data: {
                message: result.choices[0]?.message?.content || '',
                text: text,
                model: KIMI_MODEL,
                context: '128K',
                tokens_used: result.usage?.total_tokens || 0
            },
            usage: result.usage
        });
    } catch (error) {
        console.error('❌ Kimi API error:', error.response?.data || error.message);
        res.status(500).json({
            success: false,
            error: error.response?.data?.message || error.message
        });
    }
});

// ========================
// Medical Specialized Endpoint
// ========================

/**
 * Medical context-aware AI assistant
 * Optimized for clinical workflows
 */
app.post('/api/medical', async (req, res) => {
    try {
        const { query, patient_notes, language = 'arabic' } = req.body;

        const medical_system_prompt = `
أنت مساعد طبي ذكي متخصص في المجال الطبي. 
مهمتك:
- فهم المعلومات الطبية بدقة
- استخدام المصطلحات الطبية العربية الصحيحة
- الالتزام بالمعايير الطبية والأخلاقية
- تقديم التشخيصات اللازمة

معلومات عينة:
- الأعراض الشائعة في العيادات العربية
- الإجراءات الطبية القياسية
- التشخيصات المخبرات المعملة

أجب بلغة:
- العربية الفصحى المصرية (أو حسب المريض)
- أسلوب احترافي
- دقة علمية
- في حدود المعايير المهنية

الحدود:
- لا تقدم تشخيصات طبية خطيرة (أدوية بوصفة طبية)
- لا تشخيص تجاوز الدور المسموح
- أشر للمريض باستشارة طبيب
- في الحالات الطارئة، ينبغي طلب الرأي الطبيب
        `.trim();

        const response = await axios.post(
            'https://api.moonshot.cn/v1/chat/completions',
            {
                model: KIMI_MODEL,
                messages: [
                    {
                        role: 'system',
                        content: medical_system_prompt
                    },
                    {
                        role: 'user',
                        content: query
                    },
                    ...(patient_notes ? [{
                        role: 'assistant',
                        content: `ملحوظات المريض: ${patient_notes}`
                    }] : [])
                ],
                temperature: 0.5
            },
            {
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${KIMI_API_KEY}`
                }
            }
        );

        const result = response.data;

        res.json({
            success: true,
            data: {
                response: result.choices[0]?.message?.content || '',
                query: query,
                medical_context: true,
                tokens_used: result.usage?.total_tokens || 0,
                language
            }
        });
    } catch (error) {
        console.error('❌ Medical AI error:', error.response?.data || error.message);
        res.status(500).json({
            success: false,
            error: error.response?.data?.message || error.message
        });
    }
});

// ========================
// Arabic Text-to-Speech Wrapper
// ========================

/**
 * Forward TTS request to ElevenLabs (better Arabic voices)
 * Kimi has TTS but ElevenLabs is better for Arabic
 */
app.post('/api/tts-arabic', async (req, res) => {
    try {
        const { text, voice_id = 'eleven_multilingual_v2' } = req.body;

        // Check if ElevenLabs API is available
        const ELEVENLABS_API_KEY = process.env.ELEVENLABS_API_KEY;

        if (!ELEVENLABS_API_KEY) {
            return res.status(400).json({
                success: false,
                error: 'ElevenLabs API key not configured. Please add ELEVENLABS_API_KEY to .env'
            });
        }

        const response = await axios.post(
            `http://localhost:3003/api/text-to-speech`,
            {
                text,
                voice_id,
                xi_api_key: ELEVENLABS_API_KEY
            }
        );

        const result = response.data;

        res.json({
            success: true,
            data: {
                audio_url: result.url,
                filename: result.filename,
                duration: result.duration,
                size: result.size,
                provider: 'ElevenLabs (via Kimi service)'
            }
        });
    } catch (error) {
        console.error('❌ TTS wrapper error:', error.message);
        res.status(500).json({
            success: false,
            error: error.message
        });
    }
});

// ========================
// Models Information
// ========================

app.get('/api/models', async (req, res) => {
    const models = [
        {
            id: 'kimi-2.5',
            name: 'Kimi 2.5',
            provider: 'Moonshot AI',
            context: '128K tokens',
            languages: '30+ (including Arabic, Chinese, English)',
            speed: 'Fast',
            quality: 'Excellent',
            cost: 'Free (30K tokens/month)',
            medical: 'Excellent',
            arabic: '⭐⭐⭐⭐⭐⭐'
        },
        {
            id: 'kimi-1.5',
            name: 'Kimi 1.5',
            provider: 'Moonshot AI',
            context: '32K tokens',
            languages: '30+',
            speed: 'Very Fast',
            quality: 'Very Good',
            cost: 'Free',
            medical: 'Good',
            arabic: '⭐⭐⭐⭐'
        },
        {
            id: 'claude-3.5-sonnet',
            name: 'Claude 3.5 Sonnet',
            provider: 'Anthropic',
            context: '200K tokens',
            languages: '30+',
            speed: 'Fast',
            quality: 'Excellent',
            cost: '$15/1M tokens',
            medical: 'Very Good',
            arabic: '⭐⭐⭐⭐⭐'
        },
        {
            id: 'gpt-4',
            name: 'GPT-4',
            provider: 'OpenAI',
            context: '8K tokens',
            languages: '30+',
            speed: 'Fast',
            quality: 'Very Good',
            cost: '$30/1M tokens',
            medical: 'Good',
            arabic: '⭐⭐⭐'
        }
    ];

    res.json({
        success: true,
        data: {
            total: models.length,
            recommended: 'kimi-2.5',
            models
        }
    });
});

// ========================
// Usage Statistics
// ========================

app.get('/api/stats', async (req, res) => {
    try {
        // In a real implementation, this would track:
        // - Total tokens used
        // - Total requests
        // - Cost savings vs alternatives

        res.json({
            success: true,
            data: {
                service: 'Kimi AI',
                model: KIMI_MODEL,
                status: 'Free Plan (30K tokens/month)',
                tokens_available: 30000,
                tokens_used: 0,
                requests_today: 0,
                monthly_cost: '0 USD',
                savings_vs_openai: '85%',
                savings_vs_claude: '78%'
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: error.message
        });
    }
});

// ========================
// Static Files
// ========================

app.use(express.static('public'));

// ========================
// Start Server
// ========================

app.listen(PORT, () => {
    console.log(`
╔═══════════════════════════════════════════════════╗
║              🌙 Kimi AI Service (Kimi 2.5)              ║
║              Moonshot AI - Excellent Arabic            ║
╚═══════════════════════════════════════════════════╝
    `);
    console.log(`🌐 Server running on port ${PORT}`);
    console.log(`🤖 Main Model: ${KIMI_MODEL} (128K context)`);
    console.log(`🇯🇴 Arabic Support: Excellent (30+ languages)`);
    console.log(`🏥 Medical Knowledge: Built-in`);
    console.log(`⚡ Speed: Fast`);
    console.log(`💰 Cost: Free (30K tokens/month)`);
    console.log('');
    console.log('📌 Endpoints:');
    console.log(`   POST  /api/chat             - AI assistant (128K context)`);
    console.log(`   POST  /api/medical          - Medical AI (specialized)`);
    console.log(`   POST  /api/tts-arabic       - Arabic TTS (via ElevenLabs)`);
    console.log(`   GET    /api/models           - Model information`);
    console.log(`   GET    /api/health           - Health check`);
    console.log(`   GET    /api/stats            - Usage statistics`);
    console.log('');
    console.log('💡 Quick Test:');
    console.log(`   curl -X POST http://localhost:${PORT}/api/chat \\`);
    console.log(`      -H \"Content-Type: application/json\" \\`);
    console.log(`      -d '{\"text\": \"مرحباً بك\"}'`);
    console.log('');
});
