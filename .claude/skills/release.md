---
name: release
description: Full release workflow — version bump, QA gate, IPA build, TestFlight upload, git tag. Never skip the QA gate.
---

# Release Workflow — OwnUrTime iOS

## When to Activate
- Merging `develop` → `main` for a production release
- Submitting a new TestFlight build (internal or external)
- End of a phase (Phase 1 MVP, etc.)

## NEVER
- Skip the QA gate (step 3) — even for "small" releases
- Build without `--obfuscate` on production
- Push a release tag before TestFlight upload succeeds
- Deploy to prod Supabase before staging validation

---

## Step 1: Pre-Flight Checklist

```bash
git checkout develop
git pull origin develop
git status   # must be clean
```

- [ ] All Phase task checkboxes complete (`cat .claude/tasks/phase1/*.md | grep "\- \[ \]"` → zero results)
- [ ] `docs/reports/phase1/qa-report.md` status = **PASS**
- [ ] No open CRITICAL/HIGH bugs in `docs/bugs/`
- [ ] Staging TestFlight build tested and approved by internal testers

If any item is ❌ → **stop**. Fix the blocker first.

## Step 2: Version Bump

Edit `pubspec.yaml`:
```yaml
version: {major}.{minor}.{patch}+{build_number}
# build_number: use GitHub Actions run_number in CI; increment manually for local builds
```

Commit:
```
Chore: bump version to {version}
```

## Step 3: Final QA Gate (NEVER skip)

```bash
flutter analyze --fatal-infos
flutter test --coverage
grep -rn "sk-\|apiKey.*=.*['\"]" --include="*.dart" lib/
grep -r '"지금\|"잠깐\|"집중' lib/
```

Any failure → **abort release**. Fix and restart from Step 1.

Expected output:
- `flutter analyze`: 0 issues found
- `flutter test`: All tests passed
- `grep sk-`: no results
- `grep 지금`: no results

## Step 4: Merge develop → main

```bash
git checkout main
git merge develop --no-ff -m "Release v{version}"
git push origin main
```

CI/CD (`.github/workflows/cd-prod.yml`) triggers automatically:
- Builds IPA with prod Supabase + prod PostHog secrets
- Uploads to TestFlight external beta track

## Step 5: Git Tag

After CI upload succeeds:
```bash
git tag v{version} -m "Release v{version}: {one-line summary}"
git push origin v{version}
```

## Step 6: App Store Phased Release (first public release)

In App Store Connect → My Apps → {version} → Phased Release:
- Enable phased release: Day 1 → 1%, Day 3 → 5%, Day 7 → 20%, Day 21 → 100%
- Monitor PostHog for KPI drops or crash spikes during rollout
- Pause rollout if `session_completed` rate drops > 20% vs. previous version

## Step 7: Phase Summary (if end-of-phase release)

```
/phase-summary
```

Generates `docs/reports/phase1/phase-summary.md`.

## Local Build (no CI — for emergency or testing)

```bash
flutter build ipa --release \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
  --dart-define=POSTHOG_API_KEY=$POSTHOG_API_KEY \
  --obfuscate \
  --split-debug-info=./debug-info

# Upload via Xcode Organizer:
# Xcode → Window → Organizer → Archives → Distribute App → TestFlight
```

Keep `./debug-info/` out of version control (`.gitignore`).

## Rollback

If a critical bug is found post-release:
1. **Pause phased release** in App Store Connect immediately
2. Fix on a `fix/` branch → PR → `main`
3. New release from Step 1 (emergency: skip phased release → "Release to All Users")
4. Write bug report in `docs/bugs/`

## Definition of Done
- [ ] QA gate passed (all 4 checks)
- [ ] CI build succeeded and IPA uploaded to TestFlight
- [ ] Git tag pushed: `v{version}`
- [ ] Phased release enabled (production release)
- [ ] Phase summary filed (end-of-phase release only)
