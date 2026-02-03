import express, { Request, Response } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import dotenv from 'dotenv';
import { OpenAI } from 'openai';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;
const OLLAMA_URL = process.env.OLLAMA_URL || 'http://localhost:11434';
const OPENAI_API_KEY = process.env.OPENAI_API_KEY;

// Initialize OpenAI
const openai = new OpenAI({
  apiKey: OPENAI_API_KEY,
});

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
});
app.use(limiter);

// Types
interface AIRequest {
  task: string;
  content: string;
  complexity?: 'low' | 'medium' | 'high';
  language?: 'ar' | 'en' | 'mixed';
  requiresCreativity?: boolean;
  fallback?: boolean;
}

interface AIResponse {
  content: string;
  provider: 'ollama' | 'openai';
  cost: number;
  latency: number;
  model?: string;
}

// Decision Engine - Determine which AI to use
function shouldUseOllama(request: AIRequest): boolean {
  // Use Ollama for:
  if (request.complexity === 'low' && !request.requiresCreativity) return true;
  if (request.content.length < 500 && request.language === 'en') return true;
  if (['classification', 'extraction', 'sentiment_simple'].includes(request.task)) return true;
  if (request.task === 'template_generation') return true;
  
  // Use OpenAI for:
  if (request.complexity === 'high') return false;
  if (request.requiresCreativity && request.language === 'ar') return false;
  if (request.task === 'complex_analysis') return false;
  if (request.task === 'creative_writing') return false;
  
  // Default: Use Ollama to save costs
  return true;
}

// Get appropriate model based on language
function getModel(language?: string): string {
  if (language === 'ar') return 'qwen2.5:7b';
  return 'mistral:7b';
}

// Build optimized prompt
function buildPrompt(request: AIRequest): string {
  const prompts: Record<string, string> = {
    template_generation: `Generate a friendly WhatsApp message template in ${request.language} for: ${request.content}. Keep it under 100 words, professional yet warm.`,
    
    sentiment_analysis: `Analyze the sentiment and respond with ONLY ONE WORD: POSITIVE, NEGATIVE, or NEUTRAL.

Text: "${request.content}"

Sentiment:`,
    
    classification: `Classify into one category: BOOKING, CANCELLATION, INQUIRY, or COMPLAINT.

Text: "${request.content}"

Category:`,
    
    extraction: `Extract information in JSON format with keys: date, time, name, service.

Text: "${request.content}"

JSON:`,
    
    simple_response: `Provide a brief, helpful response in ${request.language}:
${request.content}`,
  };
  
  return prompts[request.task] || request.content;
}

// Call Ollama API
async function callOllama(request: AIRequest): Promise<string> {
  const model = getModel(request.language);
  const prompt = buildPrompt(request);
  
  const response = await fetch(`${OLLAMA_URL}/api/generate`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      model,
      prompt,
      stream: false,
      options: {
        temperature: request.requiresCreativity ? 0.7 : 0.3,
        num_predict: 500,
        top_k: 40,
        top_p: 0.9,
      },
    }),
  });

  if (!response.ok) {
    throw new Error(`Ollama error: ${response.statusText}`);
  }

  const data = await response.json();
  return data.response.trim();
}

// Call OpenAI API
async function callOpenAI(request: AIRequest): Promise<string> {
  const model = 'gpt-4o-mini';
  
  const messages = [
    {
      role: 'system' as const,
      content: request.language === 'ar' 
        ? 'You are a helpful assistant for a clinic management system. Respond in Arabic.'
        : 'You are a helpful assistant for a clinic management system.',
    },
    {
      role: 'user' as const,
      content: request.content,
    },
  ];

  const completion = await openai.chat.completions.create({
    model,
    messages,
    max_tokens: 500,
    temperature: request.requiresCreativity ? 0.7 : 0.3,
  });

  return completion.choices[0]?.message?.content || '';
}

// Estimate OpenAI cost
function estimateCost(request: AIRequest): number {
  const inputTokens = Math.ceil(request.content.length / 4);
  const outputTokens = 250; // estimated
  // GPT-4o-mini: $0.15 per 1M input, $0.60 per 1M output
  return (inputTokens / 1000000) * 0.15 + (outputTokens / 1000000) * 0.60;
}

// Main route
app.post('/generate', async (req: Request, res: Response) => {
  const startTime = Date.now();
  const request: AIRequest = req.body;
  
  try {
    // Validate request
    if (!request.task || !request.content) {
      return res.status(400).json({
        error: 'Missing required fields: task, content',
      });
    }

    let result: AIResponse;
    const useOllama = shouldUseOllama(request);

    if (useOllama) {
      try {
        const content = await callOllama(request);
        result = {
          content,
          provider: 'ollama',
          cost: 0.0001, // Approximate electricity cost
          latency: Date.now() - startTime,
          model: getModel(request.language),
        };
      } catch (error) {
        // Fallback to OpenAI if Ollama fails and fallback is enabled
        if (request.fallback !== false && OPENAI_API_KEY) {
          console.log('Ollama failed, falling back to OpenAI');
          const content = await callOpenAI(request);
          result = {
            content,
            provider: 'openai',
            cost: estimateCost(request),
            latency: Date.now() - startTime,
            model: 'gpt-4o-mini',
          };
        } else {
          throw error;
        }
      }
    } else {
      // Use OpenAI for complex tasks
      if (!OPENAI_API_KEY) {
        return res.status(503).json({
          error: 'OpenAI API key not configured for complex tasks',
        });
      }
      
      const content = await callOpenAI(request);
      result = {
        content,
        provider: 'openai',
        cost: estimateCost(request),
        latency: Date.now() - startTime,
        model: 'gpt-4o-mini',
      };
    }

    res.json({
      success: true,
      data: result,
    });
  } catch (error: any) {
    console.error('AI Router Error:', error);
    res.status(500).json({
      success: false,
      error: error.message || 'Internal server error',
    });
  }
});

// Health check
app.get('/health', async (req: Request, res: Response) => {
  try {
    // Check Ollama
    const ollamaHealth = await fetch(`${OLLAMA_URL}/api/tags`)
      .then(r => r.ok)
      .catch(() => false);
    
    res.json({
      status: 'ok',
      ollama: ollamaHealth ? 'connected' : 'disconnected',
      openai: OPENAI_API_KEY ? 'configured' : 'not_configured',
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    res.status(503).json({
      status: 'error',
      message: 'Service unavailable',
    });
  }
});

// Get available models
app.get('/models', async (req: Request, res: Response) => {
  try {
    const ollamaModels = await fetch(`${OLLAMA_URL}/api/tags`)
      .then(r => r.json())
      .then(data => data.models?.map((m: any) => m.name) || [])
      .catch(() => []);
    
    res.json({
      ollama: ollamaModels,
      openai: OPENAI_API_KEY ? ['gpt-4o-mini', 'gpt-4o'] : [],
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch models' });
  }
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 AI Router running on port ${PORT}`);
  console.log(`📡 Ollama URL: ${OLLAMA_URL}`);
  console.log(`🤖 OpenAI: ${OPENAI_API_KEY ? 'Configured' : 'Not configured'}`);
});
