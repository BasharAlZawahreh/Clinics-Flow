const express = require('express');
const cors = require('cors');
const axios = require('axios');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3003;

// ElevenLabs API Key
const ELEVENLABS_API_KEY = process.env.ELEVENLABS_API_KEY || 'sk_0ed8b27855c6cf13f844f9c2ab9fdbe259619a09dd8e5501';

// ElevenLabs API Base URL
const ELEVENLABS_API = 'https://api.elevenlabs.io/v1';

// Default voice model (Arabic optimized)
const DEFAULT_VOICE = 'eleven_multilingual_v2';

// Default voice settings
const DEFAULT_VOICE_SETTINGS = {
    stability: 0.5,
    similarity_boost: 0.75
    style: 'enhanced'
};

app.use(cors());
app.use(express.json());

// ========================
// Text to Speech (TTS)
// ========================

/**
 * Convert text to speech (Arabic support)
 * 
 * @param {text: string, voice_id?: string, voice_settings?: object}
 * @returns {Promise}
 */
async function textToSpeech({ text, voice_id = DEFAULT_VOICE, voice_settings = DEFAULT_VOICE_SETTINGS }) {
    try {
        console.log(`🎤 Converting to speech: ${text.substring(0, 50)}...`);

        const response = await axios.post(
            `${ELEVENLABS_API}/text-to-speech/${voice_id}`,
            {
                text,
                model_id: 'eleven_multilingual_v2',
                voice_settings,
                xi_api_key: ELEVENLABS_API_KEY,
            },
            {
                responseType: 'arraybuffer',
                headers: {
                    'Content-Type': 'application/json',
                    'xi-api-key': ELEVENLABS_API_KEY,
                },
                maxBodyLength: 10485760, // 100MB
                timeout: 30000 // 30 seconds
            }
        );

        // Save audio file
        const timestamp = Date.now();
        const filename = `speech_${timestamp}.mp3`;
        const filepath = path.join(__dirname, 'output', filename);
        
        // Ensure output directory exists
        const outputDir = path.join(__dirname, 'output');
        if (!fs.existsSync(outputDir)) {
            fs.mkdirSync(outputDir, { recursive: true });
        }

        fs.writeFileSync(filepath, Buffer.from(response.data));
        
        console.log(`✅ Saved audio to: ${filename}`);
        console.log(`📁 Path: ${filepath}`);

        return {
            success: true,
            filename,
            filepath,
            size: Buffer.byteLength(response.data),
            duration: calculateDuration(Buffer.byteLength(response.data))
        };
    } catch (error) {
        console.error('❌ Error converting text to speech:', error.response?.data || error.message);
        return {
            success: false,
            error: error.response?.data || error.message
        };
    }
}

/**
 * Calculate estimated audio duration (rough estimate: ~30KB/sec for MP3)
 */
function calculateDuration(bytes) {
    const kbps = 30; // 30 KB per second
    const seconds = bytes / (kbps * 1024);
    return Math.round(seconds * 100) / 100; // Return in centiseconds
}

// ========================
// API Routes
// ========================

/**
 * POST /api/text-to-speech
 * Convert text to speech
 */
app.post('/api/text-to-speech', async (req, res) => {
    try {
        const { text, voice_id, style, stability, similarity_boost } = req.body;

        if (!text || text.trim() === '') {
            return res.status(400).json({
                success: false,
                error: 'Text is required'
            });
        }

        // Convert Arabic numbers if needed
        const normalizedText = normalizeArabicText(text);

        // Build voice settings
        const voice_settings = {
            stability: stability || DEFAULT_VOICE_SETTINGS.stability,
            similarity_boost: similarity_boost || DEFAULT_VOICE_SETTINGS.similarity_boost,
            style: style || DEFAULT_VOICE_SETTINGS.style
        };

        // Generate speech
        const result = await textToSpeech({
            text: normalizedText,
            voice_id,
            voice_settings
        });

        if (result.success) {
            res.json({
                success: true,
                data: {
                    filename: result.filename,
                    url: `/output/${result.filename}`,
                    duration: result.duration,
                    size: result.size,
                    voice_id,
                    voice_settings
                }
            });
        } else {
            res.status(500).json(result);
        }
    } catch (error) {
        console.error('❌ Error in TTS:', error);
        res.status(500).json({
            success: false,
            error: error.message
        });
    }
});

/**
 * GET /api/voices
 * Get available voices
 */
app.get('/api/voices', async (req, res) => {
    try {
        const response = await axios.get(
            `${ELEVENLABS_API}/voices?xi_api_key=${ELEVENLABS_API_KEY}`,
            {
                headers: {
                    'xi-api-key': ELEVENLABS_API_KEY
                }
            }
        );

        const voices = response.data.voices;
        
        // Filter and categorize voices
        const categorized = {
            arabic: voices.filter(v => v.labels?.includes('arabic')),
            multilingual: voices.filter(v => v.labels?.includes('multilingual')),
            standard: voices.filter(v => !v.labels?.includes('arabic') && !v.labels?.includes('multilingual'))
        };

        res.json({
            success: true,
            data: {
                total: voices.length,
                arabic: categorized.arabic,
                multilingual: categorized.multilingual,
                standard: categorized.standard,
                recommended: 'eleven_multilingual_v2' // Best for Arabic
            }
        });
    } catch (error) {
        console.error('❌ Error fetching voices:', error);
        res.status(500).json({
            success: false,
            error: error.message
        });
    }
});

/**
 * GET /api/health
 * Health check
 */
app.get('/api/health', (req, res) => {
    res.json({
        status: 'ok',
        service: 'ElevenLabs Text-to-Speech',
        timestamp: new Date().toISOString()
    });
});

/**
 * GET /api/stats
 * Usage statistics
 */
app.get('/api/stats', async (req, res) => {
    try {
        const outputDir = path.join(__dirname, 'output');
        const files = fs.readdirSync(outputDir).filter(f => f.endsWith('.mp3'));
        
        let totalSize = 0;
        const fileStats = files.map(file => {
            const filepath = path.join(outputDir, file);
            const stats = fs.statSync(filepath);
            totalSize += stats.size;
            return {
                filename: file,
                size: stats.size,
                created: stats.mtime
            };
        });

        res.json({
            success: true,
            data: {
                total_files: files.length,
                total_size: totalSize,
                files: fileStats
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
// Utility Functions
// ========================

/**
 * Normalize Arabic text for better TTS
 */
function normalizeArabicText(text) {
    // Add diacritics if missing
    let normalized = text;
    
    // Ensure proper Arabic punctuation
    normalized = normalized
        .replace(/،/g, '، ')  // Add space after comma
        .replace(/\./g, '. ')  // Add space after period
        .replace(/؟/g, '؟ ')  // Add space after question mark
    
    return normalized.trim();
}

// ========================
// Static Files
// ========================

app.use('/output', express.static(path.join(__dirname, 'output')));

// ========================
// Start Server
// ========================

app.listen(PORT, () => {
    console.log(`
╔═════════════════════════════════════════════════════════════╗
║                     🎤 ElevenLabs Text-to-Speech Service                 ║
╚═════════════════════════════════════════════════════════════╝
    `);
    console.log(`🌐 Server running on port ${PORT}`);
    console.log(`🔑 API Key: ${ELEVENLABS_API_KEY.substring(0, 10)}...`);
    console.log(`📁 Output directory: ${path.join(__dirname, 'output')}`);
    console.log('');
    console.log('📌 Endpoints:');
    console.log(`   POST  /api/text-to-speech - Convert text to speech`);
    console.log(`   GET    /api/voices        - List available voices`);
    console.log(`   GET    /api/health       - Health check`);
    console.log(`   GET    /api/stats        - Usage statistics`);
    console.log('');
    console.log('🎤 Default Voice: eleven_multilingual_v2 (Best for Arabic)');
    console.log('');
});
