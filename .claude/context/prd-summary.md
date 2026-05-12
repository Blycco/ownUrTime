# PRD Summary — OwnUrTime v1.1
> Full PRD: `docs/01_prd/current/PRD_v1_1.md`

## Product Identity
**"If you planned it but can't start, we handle what comes next."**
Focused on the three hardest moments: initiation, maintenance, recovery.
No judgment on ADHD diagnosis — positioned around the *experience*, not the label.

---

## 5 Core Features (Section 5)

### 5-1. Initiation — 2-Min Micro-Start
- Problem: 20–40 min to start a task
- Feature: "Just 2 minutes" micro-start + AI-powered 3-step task decomposition (free: 10/day via Gemini Flash 2.0)
- Principle: No forced input, no pre-session setup, first action = 1 tap

### 5-2. Maintenance — Flexible Session Timer
- Problem: Fixed 25-min timers don't match ADHD's variable focus patterns
- Feature: 10 / 15 / 25 min presets + custom (placed last) + 3 resets/session + 1-min extend
- Distraction detection modes:
  - ① User-declared (default): "distracted" button always visible; no interruption until tapped
  - ② Adaptive check-in: new/returning users only, shown once 5 min into session, auto-dismisses in 10s
  - ③ Manual-work mode: toggle before session disables all check-ins (for reading, handwriting, etc.)

### 5-3. Recovery — 1-Tap Re-entry
- Problem: Post-interruption recovery takes 2× longer than neurotypical baseline
- Feature: distraction type classification (urgent / impulsive / rest) + context restore card + 1-tap resume
- The app acts as external working memory — context is preserved so the user doesn't have to reconstruct it

### 5-4. Switching — Auto Next-Task Connection
- Problem: 50%+ time loss during task switching
- Feature: focus-pattern-based next-task suggestion → user only decides yes/no

### 5-5. Tracking — Automatic Progress Tracking
- 5 metrics: initiation time / distraction count / recovery rate / completion rate / focus pattern
- Principle: 90% automatic (no manual logging); never show "how much wasn't done"

---

## Reward Design (Section 6)
| Layer | Trigger | Reward | Tier |
|-------|---------|--------|------|
| 1 — Immediate | Every session complete | Sound + completion animation | Free, always |
| 2 — Conditional | Hard-situation starts | Rare badge + special effect | Paid |
| 3 — Growth | Badge accumulation | App theme/skin unlocks | Paid |

**Key**: Starting on a bad day > completing 10 tasks. Rarest rewards go to the hardest starts.

---

## Onboarding (Section 7)
| Step | Behavior |
|------|----------|
| App launch | Guest mode immediately, no login required |
| Before first session | Mood check (5-level emoji) → auto-suggest session length |
| After 3rd session | Request Apple/Google Sign In |

---

## AI Features (Section 10)
| Feature | Tier | Model | Limit |
|---------|------|-------|-------|
| Task auto-decomposition | Free | Gemini Flash 2.0 | 10/day |
| Personalized insights | Paid | Gemini Pro / Claude API | Unlimited |
| Distraction pattern analysis | Paid Phase 3+ | Core ML preferred | — |

Limit UX: positive framing ("You worked hard today"), then show manual 3-step input field.

---

## MVP Phase Roadmap (Section 15)
| Phase | Duration | Key Features | Done When |
|-------|----------|-------------|-----------|
| **1** | **6 wks** | Initiation (2-min) / Maintenance (user-declared distraction) / Recovery (context card) / Layer-1 reward / Mood check / Guest mode / Supabase / iCloud backup / i18n structure | TestFlight internal test passes |
| 2 | 4 wks | Auto tracking (5 metrics) / Heatmap / Layer-2 reward / Apple Sign In / Apple Calendar (read-only) | 100 external beta users |
| 3 | 3 wks | Switching / Layer-3 reward / Widget / AI paid features / In-app purchase | App Store submission |
| 4+ | Post-launch | iPad / Android / English i18n / Next.js portal | After MAU 1,000 |

---

## Paid Conversion Triggers (Section 11)
- AI decomposition limit reached (10/day exceeded)
- Personalized AI insight shown ("Your initiation success rate peaks at 3pm")
- Layer 2/3 reward lock screens
