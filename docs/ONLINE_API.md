# Online API and Realtime Behavior

## OpenRouter

The Android client sends requests directly to `https://openrouter.ai/api/v1` using the user's own key. No application backend is required.

Settings stores the key in Android secure storage. **Tes API** calls `GET /api/v1/key`; a green CONNECTED indicator means the key was authenticated by OpenRouter, not merely stored locally.

If the test fails:

- Create a key at <https://openrouter.ai/keys>.
- Paste the key itself, or `Bearer <key>`; the app removes the wrapper.
- Check that the key is not expired, disabled, or over its credit/rate limit.
- Do not paste an OpenAI key or a placeholder such as `<OPENROUTER_API_KEY>`.
- Check the exact HTTP error shown by the app.

## TradingView

Market Center opens a live dark TradingView chart inside the APK. Users can use TradingView's own chart controls and indicators manually. The **ANALISA AI** action sends the selected symbol/timeframe context to OpenRouter.

The app does not fabricate candle, volume, order-book, liquidity, or news values that are not present in a verified source. Trading output is informational and is not financial advice.

## Release verification

Every Android release must pass:

1. dependency resolution;
2. Garuda icon generation;
3. `flutter analyze`;
4. release APK build;
5. artifact upload;
6. GitHub release publication.
