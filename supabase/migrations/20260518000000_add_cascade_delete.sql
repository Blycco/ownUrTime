-- user_profiles: CASCADE
ALTER TABLE user_profiles
  DROP CONSTRAINT user_profiles_id_fkey,
  ADD CONSTRAINT user_profiles_id_fkey
    FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE;

-- tasks: CASCADE
ALTER TABLE tasks
  DROP CONSTRAINT tasks_user_id_fkey,
  ADD CONSTRAINT tasks_user_id_fkey
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

-- sessions: CASCADE
ALTER TABLE sessions
  DROP CONSTRAINT sessions_user_id_fkey,
  ADD CONSTRAINT sessions_user_id_fkey
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

-- mood_checks: CASCADE
ALTER TABLE mood_checks
  DROP CONSTRAINT IF EXISTS mood_checks_user_id_fkey,
  ADD CONSTRAINT mood_checks_user_id_fkey
    FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
