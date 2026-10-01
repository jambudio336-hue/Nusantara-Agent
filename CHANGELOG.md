# Changelog

## Unreleased - 2026-10-01
- Fixed OpenRouter key testing to use the official `GET /api/v1/key` authentication endpoint.
- Added key normalization for pasted `Bearer`, quote, and backtick wrappers.
- Added explicit CONNECTED / CONNECTION FAILED / NOT TESTED status in Settings.
- Added live dark TradingView chart entry point from Market Center and AI analysis action.
- Added CI generation of the Garuda launcher icon before every Android release build.
- Fixed API-key diagnostics for placeholder keys and HTTP 401 responses.
- Fixed Market Radar refresh so calendar failures do not hide market quotes.
- Added CoinGecko public realtime fallback for crypto radar quotes when exchange endpoints rate-limit or return 403.
- Switched the TradingView screen to the embeddable dark widget URL and added an in-app retry/error state.
- Set the default OpenRouter route to the official `openrouter/free` router with free-model fallback.
- Added Settings guidance that free OpenRouter access still requires the user's active API key and free-tier quota.
- Added dark Garuda-inspired launcher icon for Mazkiplay AI.
- Added Android secure storage for user-provided OpenRouter and optional intelligence keys.
- Added OpenRouter auto-model discovery, free-model fallback, and resilient model failover.
- Added image and file attachments to the chat workflow; image payloads can be sent directly to vision-capable models.
- Added Chat Baru, Tools navigation, and clearer local-only/no-backend messaging.
- Added premium live intelligence dashboard as the primary workspace.
- Added consent/disclaimer onboarding with required acknowledgement.
- Added responsive Nusantara accent palette and dashboard status cards.
- Added desktop/terminal agent foundation with Ollama and OpenRouter provider modes.
- Added localhost FastAPI runtime with scoped workspace configuration.
- Expanded README with full-stack architecture, security model, and roadmap.

## 0.3.0 - 2026-09-30
- Added Forex Agent workspace with Scalping, Intraday, and Swing modes.
- Added public market candle ingestion and live snapshot timestamp.
- Added EMA 20/50/200, RSI 14, Bollinger Bands, ATR, support/resistance and Fibonacci retracement calculations.
- Added risk-based position sizing, TP 1:2 and 1:3 scenarios, and controlled layering guidance.
- Added public macro/forex news RSS context.
- Added built-in candlestick chart for manual analysis.
- Added multi-factor signal synthesis UI.
- Added explicit data limitations so unavailable broker liquidity/order-book data is never fabricated.

## 0.2.0 - 2026-09-30
- OpenRouter connection diagnostics and model discovery.
- Encrypted BYO API key storage.
- ChatGPT-style dark UI and PDF export.

## 0.1.0 - 2026-09-30
- Initial standalone Android AI agent release.
