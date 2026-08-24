# Безкоштовні AI-моделі та сервіси (Квітень 2026)
> Безкоштовні моделі станом на квітень 2026 з лімітами: текст, озвучка, зображення, відео, музика.

Дослідження проведено 28.04.2026 для відео-пайплайн — автономної YouTube-платформи.

## LLM (текст/скрипти)

| Провайдер | Модель | Free Limits | Context | Якість |
|---|---|---|---|---|
| **Google Gemini** | 2.5 Flash | 500 RPD, 250K TPM | 1M | ≈ Sonnet |
| **Google Gemini** | 2.5 Pro | 100 RPD, 250K TPM | 1M | ≈ GPT-4 |
| **Groq** | Llama 3.3 70B | 1K RPD, 6K TPM | 131K | ≈ GPT-4 |
| **Mistral** | Large | 2 RPM, 1B tok/міс | 128K | ≈ GPT-4 |
| **SambaNova** | DeepSeek V3.2 | 10-30 RPM | 131K | ≈ GPT-4 |
| **OpenRouter** | 29 моделей | 50 RPD | varies | varies |
| **NVIDIA NIM** | open-source | 40 RPM | 128K | varies |
| **Cloudflare** | Kimi K2.5 | 10K Neurons/день | 256K | varies |
| **Cerebras** | Qwen3 235B | 30 RPM, 1M tok/день | 8K cap | ≈ GPT-4 |

**Рекомендація:** Claude CLI (підписка $0) = основний. Gemini Flash = backup.

## TTS (голос)

| Сервіс | Якість | Ліцензія | GPU | Емоції | Клонування |
|---|---|---|---|---|---|
| **Chatterbox Turbo** | >ElevenLabs | MIT | Опціонально | Так | Так (5s) |
| **Fish Audio S2-Pro** | SOTA | Non-commercial* | Так | 15K+ тегів | Так |
| **Orpheus TTS** | ≈ ElevenLabs | Open | Так (RTX) | 8 тегів | Так |
| **Kokoro-82M** | Дуже добрий | Apache-2.0 | Ні (CPU!) | Обмежено | Ні |
| **VoxCPM2** | SOTA 48kHz | Apache-2.0 | 8GB VRAM | Так | Так + LoRA |
| **Edge TTS** | Добрий | Unofficial | Ні | Ні | Ні |

**Рекомендація:** Chatterbox Turbo (MIT, CPU, емоції, клонування). Edge TTS = fallback (субтитри).

## Image Gen

| Сервіс | Free Limits | API | Консистентність |
|---|---|---|---|
| **Gemini Flash Image** | 500/день | Так | Середня |
| **Together AI (Flux)** | Безліміт 3 міс | Так | Середня |
| **Cloudflare Workers AI** | ~5-10K/день | Так | Низька |
| **Pollinations.ai** | 1/15s | Так | Середня |
| **Leonardo AI** | ~20/день | Так | Висока (LoRA) |

**Рекомендація:** Pollinations (зараз) → Gemini Flash Image (апгрейд).

## Video Gen

| Сервіс | Free Limits | Тривалість | Роздільність | Watermark | I2V |
|---|---|---|---|---|---|
| **Seedance 2.0** | 100/день | до 15s | 1080p | Ні | Так |
| **Google Veo 3.1** | 50/день | до 8s | 720p | Ні | Так |
| **Arena.ai** | 3/24г | 5-10s | 1080p | Ні | Так |
| **LTX-2.3** | Безліміт (local) | varies | 720p | Ні | Так |
| **WAN 2.7** | Безліміт (local) | 5-10s | 1080p | Ні | Apache 2.0 |

**Рекомендація:** Seedance 2.0 = найкращий free (100/день, 1080p, I2V, без watermark).

## Музика

Жоден free сервіс не дає commercial rights. Мінімум Suno Pro $10/міс для монетизованого YouTube.

- Suno: 10 пісень/день (non-commercial)
- Udio: ~3/день (non-commercial)
- Для немонетизованого каналу — Suno free OK.
