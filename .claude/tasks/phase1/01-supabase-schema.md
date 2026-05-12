# Supabase Schema — Phase 1
> Agent: Claude Code (schema design + RLS) | Codex (SQL boilerplate)
> PRD ref: Section 16 (tech stack), .claude/context/folder-structure.md (schema)

## Setup
- [ ] Install Supabase CLI: `brew install supabase/tap/supabase`
- [ ] `supabase init` in project root
- [ ] `supabase start` — local dev instance running

## Migrations (supabase/migrations/)
- [ ] `20260511_01_user_profiles.sql`
  ```sql
  CREATE TABLE user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name TEXT,
    mood_check_enabled BOOLEAN DEFAULT true,
    session_count INTEGER DEFAULT 0,   -- tracks guest→auth threshold (3)
    created_at TIMESTAMPTZ DEFAULT NOW()
  );
  ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
  CREATE POLICY "users manage own profile" ON user_profiles
    USING (auth.uid() = id) WITH CHECK (auth.uid() = id);
  ```

- [ ] `20260511_02_tasks.sql`
  ```sql
  CREATE TABLE tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    decomposed_steps JSONB,       -- ["Step 1", "Step 2", "Step 3"]
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending','in_progress','completed','abandoned')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ
  );
  ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
  CREATE POLICY "users manage own tasks" ON tasks
    USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
  ```

- [ ] `20260511_03_sessions.sql`
  ```sql
  CREATE TABLE sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    task_id UUID REFERENCES tasks(id) ON DELETE SET NULL,
    target_duration_minutes INTEGER NOT NULL CHECK (target_duration_minutes > 0),
    status TEXT DEFAULT 'active' CHECK (status IN ('active','completed','abandoned')),
    distraction_count INTEGER DEFAULT 0,
    reset_count INTEGER DEFAULT 0 CHECK (reset_count <= 3),
    manual_work_mode BOOLEAN DEFAULT false,
    started_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ
  );
  ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;
  CREATE POLICY "users manage own sessions" ON sessions
    USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
  ```

- [ ] `20260511_04_distractions.sql`
  ```sql
  CREATE TABLE distractions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID REFERENCES sessions(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    distraction_type TEXT NOT NULL CHECK (distraction_type IN ('urgent','impulsive','rest')),
    occurred_at TIMESTAMPTZ DEFAULT NOW(),
    returned_at TIMESTAMPTZ
  );
  ALTER TABLE distractions ENABLE ROW LEVEL SECURITY;
  CREATE POLICY "users manage own distractions" ON distractions
    USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
  ```

- [ ] `20260511_05_mood_checks.sql`
  ```sql
  CREATE TABLE mood_checks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    session_id UUID REFERENCES sessions(id) ON DELETE SET NULL,
    mood_level INTEGER NOT NULL CHECK (mood_level BETWEEN 1 AND 5),
    checked_at TIMESTAMPTZ DEFAULT NOW()
  );
  ALTER TABLE mood_checks ENABLE ROW LEVEL SECURITY;
  CREATE POLICY "users manage own moods" ON mood_checks
    USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
  ```

## Edge Function: decompose-task
- [ ] Create supabase/functions/decompose-task/index.ts
- [ ] Accept: `{ task_title: string, user_id: string }`
- [ ] Rate limit: query tasks table for today's AI decomposition count; block if ≥ 10
- [ ] Call Gemini Flash 2.0 API with prompt: "Break this task into exactly 3 actionable steps: {title}"
- [ ] Return: `{ steps: string[], remaining_today: number }`
- [ ] Error response for limit exceeded: `{ error: "daily_limit_reached", steps_used: 10 }`

## Verify
- [ ] `supabase db reset` — all migrations apply cleanly
- [ ] `supabase functions serve decompose-task` — function responds locally
- [ ] Test RLS: query tasks as different user → returns empty
- [ ] Push to Supabase cloud project: `supabase db push` + `supabase functions deploy decompose-task`
