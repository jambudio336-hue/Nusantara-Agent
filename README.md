# Nusantara Agent 🇮🇩

Standalone Android AI Agent by M4zk1pL4y / Mas Kiplay Pekalongan Community.

## Core
- Native Android APK — **no Termux, Python, Node.js, or external localhost runtime required**.
- ChatGPT-style dark UI.
- OpenRouter BYO API key: users enter their own key in Settings.
- Live connection indicator: READY / ERROR based on an actual API request.
- Dynamic OpenRouter model discovery.
- User-selectable or Auto model mode.
- Local encrypted credential storage using Android Keystore.
- PDF export directly from assistant responses.
- Provider abstraction prepared for future Android-local inference and OpenAI-compatible providers.
- Permission/audit architecture for future device and authorized security tools.

## Security
API keys are never committed to source code. The app stores the user's OpenRouter credential locally using Android Keystore-backed encryption. Network traffic uses HTTPS.

Nusantara does not provide unrestricted destructive, credential-theft, persistence, or unauthorized exploitation automation. Security tooling is intended for systems the user is authorized to test.

## Build
GitHub Actions builds a debug APK and publishes a release artifact on version tags.

## License
Apache-2.0. See LICENSE.
