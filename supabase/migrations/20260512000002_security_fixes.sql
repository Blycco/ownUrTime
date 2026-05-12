-- H2: server-controlled rate limiting via ai_usage_log
CREATE TABLE public.ai_usage_log (
  id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  function_name TEXT        NOT NULL DEFAULT 'decompose-task',
  called_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_ai_usage_user_called ON public.ai_usage_log (user_id, called_at);
ALTER TABLE public.ai_usage_log ENABLE ROW LEVEL SECURITY;
-- SELECT only for authenticated users (for remaining_today display)
-- INSERT/UPDATE/DELETE have no policy → blocked for anon/authenticated; service role bypasses RLS
CREATE POLICY "ai_usage_select" ON public.ai_usage_log
  FOR SELECT USING (auth.uid() = user_id);

-- H3: distractions UPDATE — add session_id ownership check (mirrors INSERT fix)
DROP POLICY IF EXISTS "distractions_update" ON public.distractions;
CREATE POLICY "distractions_update" ON public.distractions
  FOR UPDATE USING (auth.uid() = user_id)
  WITH CHECK (
    auth.uid() = user_id AND
    EXISTS (
      SELECT 1 FROM public.sessions s
      WHERE s.id = session_id AND s.user_id = auth.uid()
    )
  );

-- H4: replace user_profiles UPDATE RLS with SECURITY DEFINER functions
-- Direct UPDATE removed to prevent client-side session_count manipulation
DROP POLICY IF EXISTS "user_profiles_update" ON public.user_profiles;

CREATE OR REPLACE FUNCTION public.update_user_profile(
  p_display_name       TEXT    DEFAULT NULL,
  p_mood_check_enabled BOOLEAN DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  UPDATE public.user_profiles
  SET
    display_name       = COALESCE(p_display_name, display_name),
    mood_check_enabled = COALESCE(p_mood_check_enabled, mood_check_enabled)
  WHERE id = auth.uid();
END;
$$;
GRANT EXECUTE ON FUNCTION public.update_user_profile TO authenticated;

CREATE OR REPLACE FUNCTION public.increment_session_count()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  UPDATE public.user_profiles
  SET session_count = session_count + 1
  WHERE id = auth.uid();
END;
$$;
GRANT EXECUTE ON FUNCTION public.increment_session_count TO authenticated;
