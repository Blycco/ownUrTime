CREATE TABLE public.mood_checks (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  session_id UUID REFERENCES public.sessions(id) ON DELETE SET NULL,
  mood_level INTEGER NOT NULL CHECK (mood_level BETWEEN 1 AND 5),
  checked_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_mood_checks_user_id ON public.mood_checks (user_id);
CREATE INDEX idx_mood_checks_session_id ON public.mood_checks (session_id)
  WHERE session_id IS NOT NULL;

ALTER TABLE public.mood_checks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "mood_checks_select" ON public.mood_checks
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "mood_checks_insert" ON public.mood_checks
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "mood_checks_update" ON public.mood_checks
  FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "mood_checks_delete" ON public.mood_checks
  FOR DELETE USING (auth.uid() = user_id);
