# Nusantara Agent 🇮🇩 / Mazkiplay AI

**Nusantara Agent** adalah platform AI lokal/online-first dengan client Android, dashboard web lokal, dan agent terminal untuk workflow AI, software engineering, authorized security testing, OSINT, dan trading research.

> Brand APK: **Mazkiplay AI**  
> Agent identity: **Nusantara Agent**  
> Creator attribution: **M4ZK1PLAY / Mas Kiplay Pekalongan Community**

## Product goals

- Chat-style AI UI yang responsif untuk Android dan web.
- BYO API key: OpenRouter/OpenAI-compatible provider.
- Provider discovery dan pemilihan model dinamis.
- Fallback provider lokal seperti Ollama untuk deployment desktop.
- Penyimpanan lokal untuk chat history, journal, preferences, dan credential material.
- Upload gambar dan berkas untuk workflow AI.
- Dashboard live: AI provider, security intelligence, market context, dan system status.
- Security workspace: CVE/KEV, DNS/HTTP/SSL/IP intelligence, password hygiene, code review, OSINT publik, dan bug-bounty workflow.
- Trading workspace: chart/candle analysis, indicators, risk sizing, journal, dan macro/news context.
- PDF export dan audit/logging.
- Integrasi Telegram/WhatsApp melalui connector/bot yang dikonfigurasi pengguna.
- Fokus rilis ini adalah APK Android standalone; runtime desktop tetap dipisahkan sebagai eksperimen opsional.

## Security model

Nusantara Agent **bukan** mesin unrestricted attack atau credential-theft. Modul keamanan ditujukan untuk aset yang pengguna miliki atau berwenang menguji. Fitur ofensif dibatasi ke workflow yang aman seperti lab/CTF, code review, vulnerability triage, proof-of-concept non-destructive, scanning yang dibatasi scope, dan bug-bounty research.

Agent terminal menggunakan prinsip:
1. workspace sandbox;
2. explicit permission untuk tool berisiko;
3. command preview/audit;
4. secret tidak ditulis ke source;
5. provider/API key tetap berada pada environment atau secure local storage;
6. network tool memiliki scope/timeout/rate-limit.

## Architecture

```
Nusantara-Agent/
├── lib/                       # Flutter Android/Web client
│   ├── screens/               # Dashboard, Chat, Tools, Journal, Settings
│   ├── services/              # OpenRouter, storage, intelligence, connectivity
│   ├── widgets/               # charts, cards, responsive components
│   └── models/
├── agent/                     # Desktop/terminal agent (Python)
│   ├── providers/             # Ollama + OpenAI-compatible providers
│   ├── tools/                 # safe tool registry
│   ├── security/              # authorized security workflows
│   ├── workspace/             # scoped local workspace
│   └── web/                   # localhost dashboard/API
├── web/                       # static/local dashboard
├── docs/                      # architecture, threat model, roadmap
├── assets/                    # app assets
└── .github/workflows/         # CI/release
```

## Online data

AI traffic can use OpenRouter or another OpenAI-compatible provider. Public intelligence modules use documented public APIs/feeds. The application does not fabricate unavailable market/order-book/security data.

## Local-first storage

Chat history, journals, preferences, and user configuration are stored locally on the device/client. OpenRouter API key disimpan melalui secure storage platform Android. Request AI langsung dari APK ke OpenRouter; tidak ada backend atau server aplikasi yang wajib, dan provider credentials tidak di-commit ke Git.

## Roadmap

### Phase 1 — Foundation
- [x] Android APK shell
- [x] Consent/disclaimer onboarding
- [x] responsive Chat UI
- [x] local history/journal
- [x] OpenRouter BYO key
- [x] streaming responses
- [x] dynamic model discovery
- [x] image/file picker
- [x] live dashboard

### Phase 2 — Intelligence
- [ ] multimodal image analysis pipeline
- [ ] text/code/document extraction
- [ ] provider abstraction
- [ ] Ollama desktop provider
- [ ] model capability discovery
- [ ] usage/token telemetry
- [ ] PDF export everywhere

### Phase 3 — Security
- [x] CISA KEV/NVD context
- [x] IP intelligence
- [x] SSL audit
- [x] password breach range check
- [ ] DNS/WHOIS/HTTP header workspace
- [ ] CVE triage and remediation assistant
- [ ] scoped web scanner
- [ ] OSINT workspace
- [ ] bug-bounty project tracker
- [ ] evidence vault

### Phase 4 — Trading
- [x] public market candle ingestion
- [x] technical indicators
- [x] risk sizing
- [x] trade journal
- [ ] multi-timeframe workspace
- [ ] macro calendar aggregation
- [ ] chart screenshot analysis
- [ ] alerts
- [ ] portfolio analytics

### Phase 5 — Agent
- [ ] Python terminal runtime
- [ ] localhost web dashboard
- [ ] permission manager
- [ ] safe command runner
- [ ] scheduled tasks
- [ ] connector framework
- [ ] Telegram/WhatsApp integrations
- [ ] Windows/macOS/Linux packaging
- [ ] optional Android remote-control bridge with explicit user permissions

### Phase 6 — Hardening
- [ ] threat model
- [ ] secure secret storage per platform
- [ ] rate limits
- [ ] audit logs
- [ ] signed releases
- [ ] dependency/SBOM checks
- [ ] crash reporting opt-in
- [ ] reproducible CI builds

## Build

Android release is built by GitHub Actions. Before a release is considered final, CI must pass:
- dependency resolution
- `flutter analyze`
- release APK build
- artifact upload
- release publication
- runtime smoke test where available

## Disclaimer

AI output can be wrong. Trading analysis is informational and not financial advice. Security tooling must only be used on authorized targets.

## License

Apache-2.0. See [LICENSE](LICENSE).
