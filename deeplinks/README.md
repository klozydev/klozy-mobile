# klozy.store deep links (verified App Links + Universal Links)

Links like `https://klozy.store/product/123`, `https://klozy.store/users/abc`,
`https://klozy.store/orders/o1`, `https://klozy.store/chat/<id>` open the app
directly (no browser, no chooser) once the steps below are done. AutoRoute
matches them by path — no app code change is needed (the deep-link builder
already passes `https` links through unchanged).

## 1. Host the two files (REQUIRED — must be HTTPS, no redirects)

Serve these at the apex domain (and `www`):

| File | URL | Content-Type |
| --- | --- | --- |
| `assetlinks.json` | `https://klozy.store/.well-known/assetlinks.json` | `application/json` |
| `apple-app-site-association` | `https://klozy.store/.well-known/apple-app-site-association` | `application/json` (NO `.json` extension) |

Both are in `deeplinks/.well-known/`. Requirements:
- HTTPS with a valid cert, reachable publicly, **HTTP 200, no redirect**.
- AASA served as raw JSON, **no `.json` extension**, `Content-Type: application/json`.

## 2. Android — already wired

`AndroidManifest.xml` has the `autoVerify="true"` intent-filter for
`https://klozy.store` + `https://www.klozy.store`. `assetlinks.json` lists:
- **Upload key** SHA-256: `FD:C1:…:31`
- **Debug key** SHA-256: `C5:29:…:F1`

⚠️ If the app is distributed via **Google Play App Signing**, Play re-signs with
its own key. Add that key's SHA-256 to `assetlinks.json` too — copy it from
**Play Console → Setup → App signing → App signing key certificate (SHA-256)**.
Without it, verification fails on Play-installed builds.

Verify after hosting:
```
adb shell pm verify-app-links --re-verify com.klozy.app
adb shell pm get-app-links com.klozy.app   # state should be "verified"
```

## 3. iOS — entitlement wired, capability needs enabling

`Runner.entitlements` declares `applinks:klozy.store`, `applinks:www.klozy.store`.
Also do, once:
- Apple Developer portal → Identifiers → `com.klozy.app` → enable **Associated
  Domains** capability, then regenerate the provisioning profile.
- Xcode → Runner target → Signing & Capabilities → **Associated Domains** present
  with `applinks:klozy.store`.

AASA `appID` = `N3NCZ374Z6.com.klozy.app` (Team `N3NCZ374Z6` + bundle
`com.klozy.app`). Apple caches the AASA — test on a real device, reinstall after
hosting. Validate at: https://branch.io/resources/aasa-validator/ or
`https://app-site-association.cdn-apple.com/a/v1/klozy.store`.

## 4. Test
```
# Android
adb shell am start -a android.intent.action.VIEW -d "https://klozy.store/product/123"
# iOS: tap a https://klozy.store/... link in Notes/Messages (not Safari address bar)
```
