# Hook: Pre-Commit

Run before every commit:

```bash
# 0. Soft guard: warn if commit frequency is too high in a short window
recent_commits=$(git log --since="30 minutes ago" --pretty=oneline | wc -l | tr -d ' ')
if [ "${recent_commits}" -ge 8 ]; then
  echo "[WARN] ${recent_commits} commits in last 30 minutes. Consider squashing micro-commits into meaningful units."
fi

# 1. Static analysis — must be zero warnings
flutter analyze

# 2. Format check — auto-apply if needed
dart format --set-exit-if-changed .

# 3. Tests — must pass
flutter test

# 4. Build verification — must pass (when Apple toolchain/runtime is available)
flutter build ios --simulator --debug
flutter build macos --debug

# 5. Secret scan — must find nothing
grep -rn "sk-\|apiKey\s*=\s*['\"].\|supabaseKey\s*=\s*['\"]" \
  --include="*.dart" lib/
```

On failure:
- `flutter analyze` fails → fix warnings, retry
- `flutter test` fails → diagnose and fix, **do not commit**
- build fails → fix build/config before commit (if runtime/toolchain missing, document and skip with explicit warning)
- Secret found → **stop immediately**, move to .env, re-scan before committing

Additional policy:
- This hook emits warnings for over-fragmented commit cadence; it does not block commits.
- Before PR/merge, clean noisy history (interactive rebase or squash merge) into meaningful commits.
