CREATE TABLE public.sessions (
  id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id                 UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  task_id                 UUID REFERENCES public.tasks(id) ON DELETE SET NULL,
  target_duration_minutes INTEGER NOT NULL CHECK (target_duration_minutes > 0),
  status                  TEXT NOT NULL DEFAULT 'active'
                          CHECK (status IN ('active', 'completed', 'abandoned')),
  distraction_count       INTEGER NOT NULL DEFAULT 0 CHECK (distraction_count >= 0),
  reset_count             INTEGER NOT NULL DEFAULT 0 CHECK (reset_count BETWEEN 0 AND 3),
  manual_work_mode        BOOLEAN NOT NULL DEFAULT false,
  started_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at            TIMESTAMPTZ
);

CREATE INDEX idx_sessions_user_id ON public.sessions (user_id);
CREATE INDEX idx_sessions_task_id ON public.sessions (task_id);

ALTER TABLE public.sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "sessions_select" ON public.sessions
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "sessions_insert" ON public.sessions
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "sessions_update" ON public.sessions
  FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "sessions_delete" ON public.sessions
  FOR DELETE USING (auth.uid() = user_id);
