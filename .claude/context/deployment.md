# Deployment & Zero-Downtime Strategy — OwnUrTime
> Read when: writing DB migrations, releasing a new version, or planning a rollback.

## Environment Separation
| Env | Supabase Project | PostHog | TestFlight Track | Triggered By |
|-----|-----------------|---------|-----------------|-------------|
| staging | `ownurtime-staging` | staging project | Internal | merge to `develop` |
| production | `ownurtime-prod` | prod project | External beta | merge to `main` |

Migration flow: **staging first, always**
```
1. supabase db push --project-ref <staging-ref>   → test with staging build
2. Verify: run through golden path on TestFlight internal
3. supabase db push --project-ref <prod-ref>       → only after staging passes
4. Merge to main → triggers prod CD
```

## Supabase: Zero-Downtime Migration Rules

The running Flutter app and the new migration must be compatible simultaneously
(App Store review takes ~24h — old app version is live during that window).

| Rule | Example |
|------|---------|
| Additive only — add columns, never rename/drop | `ALTER TABLE tasks ADD COLUMN priority INT DEFAULT 0` |
| New columns must be nullable or have DEFAULT | Existing rows must not break |
| Two-phase rename | Phase A: add new col + write both; Phase B: drop old col after app update is live |
| Edge Function: new incompatible logic → new path | `/v2/decompose-task`, not overwrite `/decompose-task` |
| RLS changes in transactions | Never leave a table unprotected mid-migration |
| Test migration reversal | Every migration has a matching rollback migration file |

**Migration file naming**: `supabase/migrations/{timestamp}_{description}.sql`

## App Store: Staged Rollout
After App Store approval → enable **Phased Release** in App Store Connect:

| Day | User % | Action |
|-----|--------|--------|
| 1 | 1% | Monitor PostHog: crash rate, KPI delta |
| 2 | 2% | |
| 3 | 5% | |
| 4 | 10% | |
| 7 | 20% | |
| 14 | 50% | |
| 21 | 100% | |

**Pause rollout if:**
- PostHog `session_completed` rate drops > 20% vs. previous version
- Crash rate spikes (Xcode Organizer / Sentry if added)
- Any CRITICAL bug reported by internal testers

**Emergency release**: App Store Connect → "Release to All Users" bypasses phased rollout.

## Rollback Plan

| Layer | Problem | Rollback |
|-------|---------|---------|
| Flutter app | Critical bug post-release | Pause phased rollout; users on previous version stay there; submit hotfix |
| Supabase migration | Data corruption or query failures | Apply reverse migration SQL; verify data integrity |
| Edge Function | Broken decompose-task | `supabase functions deploy decompose-task` from previous git tag |
| Staging only | Bad migration on staging | Drop/recreate staging project (no real user data) |

Reverse migration example (additive rollback):
```sql
-- Reverse of: ADD COLUMN priority INT DEFAULT 0
ALTER TABLE tasks DROP COLUMN IF EXISTS priority;
```

## Feature Flags (Phase 2+)
Use Supabase table to toggle features without App Store release:
```sql
CREATE TABLE feature_flags (
  key TEXT PRIMARY KEY,
  enabled BOOLEAN DEFAULT false,
  min_version TEXT  -- e.g. '1.2.0' — only enable for versions ≥ this
);
```
Flutter: fetch on app launch, cache in Riverpod `Provider<Map<String, bool>>`.
Allows disabling a broken Phase 2 feature while keeping Phase 1 live.

## Supabase Free Tier Limits (monitor before hitting)
| Resource | Free Limit | Alert At |
|----------|-----------|---------|
| Database | 500 MB | 400 MB |
| Monthly Active Users | 50,000 | 40,000 |
| Edge Function invocations | 500,000 / month | 400,000 |
| Storage | 1 GB | 800 MB |

Add Supabase usage alerts in dashboard → Settings → Billing alerts.
Upgrade to Pro ($25/mo) before hitting limits — Pro adds PITR (Point-in-Time Recovery).
