# CI/CD Pipeline — OwnUrTime
> Read when: setting up GitHub Actions, troubleshooting build failures, adding new secrets.

## Pipeline Overview
```
PR opened        → CI: analyze + test + coverage check
Merge to develop → CD: build → staging Supabase + TestFlight internal
Merge to main    → CD: build → prod Supabase + TestFlight external beta
Tag v*.*.*       → CD: App Store submission (manual trigger)
```

## Branch Strategy
```
main      → always deployable; prod Supabase; TestFlight external beta
develop   → integration; staging Supabase; TestFlight internal
feat/*    → feature branches; PR → develop
fix/*     → hotfix; PR → main, then cherry-pick to develop
```

## GitHub Actions: CI (`.github/workflows/ci.yml`)
```yaml
name: CI
on: [pull_request]
jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
          channel: stable
      - run: flutter pub get
      - run: flutter pub audit              # M2: supply chain check
      - run: flutter analyze --fatal-infos
      - run: flutter test --coverage
      - run: dart pub global activate coverage
      - run: format_coverage --lcov -o coverage/lcov.info --report-on lib
      - uses: VeryGoodOpenSource/very_good_coverage@v2
        with:
          min_coverage: 80
          path: coverage/lcov.info
          exclude: "**/*.g.dart **/*.freezed.dart"
```

## GitHub Actions: CD — Staging (`.github/workflows/cd-staging.yml`)
```yaml
name: CD Staging
on:
  push:
    branches: [develop]
jobs:
  deploy:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with: { flutter-version: '3.x', channel: stable }
      - name: Install certificates
        env:
          CERTIFICATE_P12: ${{ secrets.APPLE_DISTRIBUTION_CERTIFICATE_P12 }}
          CERTIFICATE_PASSWORD: ${{ secrets.APPLE_DISTRIBUTION_CERTIFICATE_PASSWORD }}
          PROVISIONING_PROFILE: ${{ secrets.PROVISIONING_PROFILE_BASE64 }}
        run: |
          echo "$CERTIFICATE_P12" | base64 --decode > cert.p12
          security create-keychain -p "" build.keychain
          security import cert.p12 -k build.keychain -P "$CERTIFICATE_PASSWORD" -T /usr/bin/codesign
          security set-key-partition-list -S apple-tool:,apple: -s -k "" build.keychain
          echo "$PROVISIONING_PROFILE" | base64 --decode > profile.mobileprovision
          mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
          cp profile.mobileprovision ~/Library/MobileDevice/Provisioning\ Profiles/
      - run: flutter pub get
      - run: |
          flutter build ipa --release \
            --dart-define=SUPABASE_URL=${{ secrets.SUPABASE_STAGING_URL }} \
            --dart-define=SUPABASE_ANON_KEY=${{ secrets.SUPABASE_STAGING_ANON_KEY }} \
            --dart-define=POSTHOG_API_KEY=${{ secrets.POSTHOG_STAGING_KEY }} \
            --obfuscate --split-debug-info=./debug-info
      - uses: apple-actions/upload-testflight-build@v1
        with:
          app-path: build/ios/ipa/*.ipa
          issuer-id: ${{ secrets.APP_STORE_ISSUER_ID }}
          api-key-id: ${{ secrets.APP_STORE_API_KEY_ID }}
          api-private-key: ${{ secrets.APP_STORE_API_PRIVATE_KEY }}
```

## GitHub Actions: CD — Production (`.github/workflows/cd-prod.yml`)
Same as staging but uses prod secrets:
```yaml
on:
  push:
    branches: [main]
# Replace secrets:
#   SUPABASE_STAGING_URL → SUPABASE_URL
#   SUPABASE_STAGING_ANON_KEY → SUPABASE_ANON_KEY
#   POSTHOG_STAGING_KEY → POSTHOG_API_KEY
```

## Required GitHub Secrets
Set in: GitHub repo → Settings → Secrets and variables → Actions

| Secret | Description |
|--------|-------------|
| `SUPABASE_URL` | Production Supabase project URL |
| `SUPABASE_ANON_KEY` | Production anon key (safe to use in client) |
| `SUPABASE_STAGING_URL` | Staging Supabase project URL |
| `SUPABASE_STAGING_ANON_KEY` | Staging anon key |
| `POSTHOG_API_KEY` | Production PostHog project key |
| `POSTHOG_STAGING_KEY` | Staging PostHog project key |
| `APP_STORE_ISSUER_ID` | App Store Connect API issuer ID |
| `APP_STORE_API_KEY_ID` | App Store Connect API key ID |
| `APP_STORE_API_PRIVATE_KEY` | App Store Connect API private key (.p8 contents) |
| `APPLE_DISTRIBUTION_CERTIFICATE_P12` | Distribution cert, base64-encoded |
| `APPLE_DISTRIBUTION_CERTIFICATE_PASSWORD` | P12 password |
| `PROVISIONING_PROFILE_BASE64` | Ad-hoc or App Store provisioning profile, base64 |

## Semantic Versioning
- Format: `v{major}.{minor}.{patch}` — tag on main for App Store release
- `pubspec.yaml`: `version: 1.0.0+$BUILD_NUMBER`
- Build number = `${{ github.run_number }}` (auto-increments, never reused)
- Breaking changes → major bump; new features → minor; fixes → patch

## Supabase Migration in CD
```bash
# In CD workflow, before Flutter build:
- run: |
    npm install -g supabase
    supabase db push --project-ref ${{ secrets.SUPABASE_PROJECT_REF }}
```
Staging migration runs before prod — never push to prod without staging validation.
