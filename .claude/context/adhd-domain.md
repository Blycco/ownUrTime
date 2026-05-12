# ADHD Domain Knowledge — OwnUrTime
> Based on PRD Sections 2–4. Reference this before any UX or feature decision.

## Core Insight
> "The ADHD brain isn't *unable* — it can only act on what is *immediately interesting or rewarding*.
> Own Ur Time supplies External Scaffolding to take over the executive function work."

---

## 4 Executive Function Areas & App Response
| Area | Problem | Evidence | App Feature |
|------|---------|----------|-------------|
| **Initiation** | 20–40 min to start | [1] | 2-min micro-start + AI task decomposition |
| **Maintenance** | 2–3× more distractions than neurotypical | [2] | Flexible timer, 3-mode distraction detection |
| **Switching** | 50%+ time loss during task transitions | [3] | Pattern-based next-task auto-suggestion |
| **Recovery** | 2× longer to recover after interruption | [2] | Context restore card, 1-tap re-entry |

---

## Neurological Root Causes

### ① Dopamine / Norepinephrine Dysregulation
- Without predicted reward, prefrontal cortex fails to fire initiation signal → task delay
- Weak inhibition of external stimuli → attention drift
- **App response**: Layer-1 immediate reward, 2-min start (fast win), AI removes friction

### ② Prefrontal–Basal Ganglia Circuit Deficit
- Working memory loses task context when interrupted → recovery failure
- High cost for task switching
- **App response**: Context restore card acts as external working memory; next-task auto-suggestion absorbs the switching decision

### ③ Time Blindness
- Poor estimation of task duration
- Deadlines feel distant → indefinite delay
- **App response**: Session timer (external time structure), calendar integration for meeting buffers (Phase 2)

---

## UX Principles (apply to all code and design decisions)

### Minimize Initiation Barrier
- First action is always **1 tap** — no multi-step flow before starting
- No forced input (task name is optional)
- No forced pre-session setup
- Guest mode default — no login before 3rd session

### Never Show Failure
- Empty heatmap days → left blank (never filled with grey or "0")
- Express as "5 active days in the last 7" not "7-day streak broken"
- Comparison baseline = yesterday's self only
- No incomplete/missed stats on main screen; stats are opt-in

### Don't Interrupt Focus
- App never initiates distraction check unless user declares it (default: user-declared mode)
- No ads ever — unexpected stimuli = distraction trigger
- Manual-work mode: all check-ins disabled for off-screen tasks (reading, writing, instruments)

### Avoid Shame Triggers
- AI limit reached: "You worked hard today" (positive framing), not "limit exceeded"
- Rarest rewards for hardest starts: starting on a bad-mood day outweighs completing 10 tasks
- After 3+ days of absence: welcome back, no guilt

---

## Target Users

### Primary — ADHD-diagnosed adults
- Age: 18–45
- Diagnosis: DSM-5-TR / ICD-11 criteria
- Medication: irrelevant (med reminders available as opt-in)
- Context: remote work, study, freelance — environments requiring self-managed time

### Secondary — Undiagnosed, experience-based
- Frequently takes 20+ min to start tasks
- Loses focus and drifts mid-task
- Hard to resume after interruptions
- Task switching takes much longer than expected

### Positioning Principle
No diagnosis label inside the app. The entry criterion is the *experience*, not the clinical status.

---

## Comorbidities (Section 8)
- Anxiety disorder comorbidity: 47%
- Depression comorbidity: 19–32%
- App is **not a medical device** — must state clearly in app that it doesn't replace diagnosis/treatment
- Low mood check → auto-suggest short session (10 min)
- Medication reminder: opt-in only, no pressure
