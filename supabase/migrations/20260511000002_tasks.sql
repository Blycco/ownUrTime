CREATE TABLE public.tasks (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id          UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title            TEXT NOT NULL,
  decomposed_steps JSONB,
  status           TEXT NOT NULL DEFAULT 'pending'
                   CHECK (status IN ('pending', 'in_progress', 'completed', 'abandoned')),
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  started_at       TIMESTAMPTZ,
  completed_at     TIMESTAMPTZ
);

CREATE INDEX idx_tasks_user_id ON public.tasks (user_id);
CREATE INDEX idx_tasks_user_decomposed_at ON public.tasks (user_id, created_at)
  WHERE decomposed_steps IS NOT NULL;

ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "tasks_select" ON public.tasks
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "tasks_insert" ON public.tasks
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "tasks_update" ON public.tasks
  FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "tasks_delete" ON public.tasks
  FOR DELETE USING (auth.uid() = user_id);
