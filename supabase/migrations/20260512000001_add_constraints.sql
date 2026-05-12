-- M1: tasks.title 길이 제약
ALTER TABLE public.tasks
  ADD CONSTRAINT tasks_title_length CHECK (char_length(title) BETWEEN 1 AND 500);

-- M2: user_profiles.display_name 길이 제약
ALTER TABLE public.user_profiles
  ADD CONSTRAINT user_profiles_display_name_length
  CHECK (display_name IS NULL OR char_length(display_name) <= 100);

-- M3: distractions INSERT RLS — session_id 소유권 검증
DROP POLICY IF EXISTS "distractions_insert" ON public.distractions;
CREATE POLICY "distractions_insert" ON public.distractions
  FOR INSERT WITH CHECK (
    auth.uid() = user_id AND
    EXISTS (
      SELECT 1 FROM public.sessions s
      WHERE s.id = session_id AND s.user_id = auth.uid()
    )
  );
