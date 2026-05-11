---
name: migrate
description: Safe Supabase schema migration — write SQL, test on staging, deploy to prod. Never deploy to prod without staging validation.
---

# Supabase Migration Workflow — OwnUrTime

## When to Activate
- Adding a new table or column
- Modifying RLS policies
- Deploying a new or updated Edge Function
- Any schema change that affects the running Flutter app

## Core Rule
**Staging first, always.** A production migration that breaks the live app cannot be quickly rolled back — App Store review takes ~24h. Design every migration to be safe with the *current* app version still running.

---

## Step 1: Write the Migration

```bash
supabase migration new {snake_case_description}
# Creates: supabase/migrations/{timestamp}_{description}.sql
```

**Additive-only rules:**
```sql
-- ✅ Safe: add nullable column
ALTER TABLE tasks ADD COLUMN priority INT DEFAULT 0;

-- ✅ Safe: add new table
CREATE TABLE feature_flags (key TEXT PRIMARY KEY, enabled BOOLEAN DEFAULT false);

-- ❌ Unsafe: rename column (breaks current app)
ALTER TABLE tasks RENAME COLUMN title TO name;

-- ❌ Unsafe: drop column (breaks current app)
ALTER TABLE tasks DROP COLUMN old_field;
```

If you need to rename: use **two-phase rename**:
- Phase A (this release): add new column, write to both old + new in app
- Phase B (next release): drop old column after new app version is live

**New columns must always have DEFAULT or be nullable:**
```sql
-- ✅ Existing rows won't break
ALTER TABLE sessions ADD COLUMN mood_after INT DEFAULT NULL;
ALTER TABLE tasks ADD COLUMN priority INT NOT NULL DEFAULT 0;
```

## Step 2: Write the Reverse Migration (same session, required)

```sql
-- File: supabase/migrations/{timestamp}_reverse_{description}.sql
-- Used for rollback if prod migration causes issues

ALTER TABLE tasks DROP COLUMN IF EXISTS priority;
```

## Step 3: RLS Policy (if new table)

Every new table needs an RLS policy. Without it, no Flutter client can read/write.

```sql
-- Enable RLS
ALTER TABLE {table} ENABLE ROW LEVEL SECURITY;

-- User can only access their own rows
CREATE POLICY "{table}_user_policy" ON {table}
  FOR ALL USING (auth.uid() = user_id);
```

Test the policy in Supabase Studio SQL editor before proceeding.

## Step 4: Deploy to Staging

```bash
supabase db push --project-ref {staging-project-ref}
```

Verify in Supabase Studio (staging):
- [ ] New column/table appears in Table Editor
- [ ] RLS policy is active (Test with a non-owner user_id → access denied)
- [ ] Existing data is not corrupted

Run the staging TestFlight build and complete the golden path:
- Guest → Task → Session → Distraction → Recovery → Reward

## Step 5: Deploy Edge Function (if changed)

```bash
# Staging first
supabase functions deploy {function-name} --project-ref {staging-project-ref}

# Test: call the function from staging Flutter build
# Verify: rate limiting still works, Gemini response format unchanged

# Production
supabase functions deploy {function-name} --project-ref {prod-project-ref}
```

If incompatible changes: deploy to `/v2/{function-name}` instead of overwriting.

## Step 6: Deploy to Production

Only after staging validation passes:

```bash
supabase db push --project-ref {prod-project-ref}
```

Verify in Supabase Studio (prod):
- [ ] Migration applied
- [ ] No data corruption
- [ ] RLS policy active

## Step 7: ADR (schema structure changes only)

If the migration changes the overall data model (new entity, significant restructure):

Create `docs/decisions/{YYYY-MM-DD}-{title}.md` using `.claude/templates/adr.md`.

Fill:
- Context: why this schema change was needed
- Decision: what was added/changed
- Consequences: what queries/code changed

## Rollback

If prod migration causes issues:

```bash
# Apply reverse migration
supabase db push --project-ref {prod-project-ref}
# (using the reverse migration SQL from Step 2)
```

For Edge Function rollback:
```bash
# Redeploy previous version from git tag
git checkout v{previous-version} -- supabase/functions/{function-name}/
supabase functions deploy {function-name} --project-ref {prod-project-ref}
git checkout develop   # restore
```

## Definition of Done
- [ ] Migration is additive only; new columns have DEFAULT or NULL
- [ ] Reverse migration written and committed
- [ ] RLS policy tested on staging
- [ ] Golden path manual test passed on staging TestFlight
- [ ] Production migration applied and verified
- [ ] ADR written (if data model changed)
