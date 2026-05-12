CREATE TABLE public.distractions (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id       UUID NOT NULL REFERENCES public.sessions(id) ON DELETE CASCADE,
  user_id          UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  distraction_type TEXT NOT NULL
                   CHECK (distraction_type IN ('urgent', 'impulsive', 'rest')),
  occurred_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  returned_at      TIMESTAMPTZ
);

CREATE INDEX idx_distractions_session_id ON public.distractions (session_id);
CREATE INDEX idx_distractions_user_id ON public.distractions (user_id);

ALTER TABLE public.distractions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "distractions_select" ON public.distractions
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "distractions_insert" ON public.distractions
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "distractions_update" ON public.distractions
  FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "distractions_delete" ON public.distractions
  FOR DELETE USING (auth.uid() = user_id);
