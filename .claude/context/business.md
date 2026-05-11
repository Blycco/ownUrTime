# Business — OwnUrTime
> Based on PRD Sections 11–13.

## Revenue Model: Freemium

### Free Tier
- Core 3 features (initiation, maintenance, recovery)
- Session duration customization (10/15/25 min + custom)
- Mood check
- Medication reminder (opt-in)
- Layer-1 immediate reward
- AI task decomposition (10/day)
- Basic heatmap

### Paid Tier (Subscription)
- Personalized AI recommendations (optimal start-time alerts)
- Distraction pattern analysis
- Detailed weekly reports
- Layer 2 & 3 rewards (badges, themes, skins)
- Advanced widget
- Apple Calendar integration
- AI task decomposition (unlimited)

### Pricing
| Plan | Price | Display on payment screen |
|------|-------|--------------------------|
| Monthly | ₩4,900/mo | — |
| Annual | ₩33,000/yr | "₩2,750/mo" (44% vs monthly) |

- App Store fee: 15% (small business program)
- **Ads: permanently banned** — unexpected stimuli = distraction trigger

---

## Key Paid Conversion Touchpoints (implement these first)
1. AI decomposition limit screen (after 10/day)
2. Personalized AI insight exposed ("Your initiation success peaks at 3pm")
3. Layer 2/3 reward lock screen

---

## KPIs (behavioral metrics, auto-collected via PostHog)
| Metric | Definition | Priority |
|--------|-----------|----------|
| Initiation conversion | App open → 2-min start tap rate | P1 |
| Session completion rate | % of sessions completed | P1 |
| Day-2 retention | Next-day return rate | P1 |
| Recovery rate | % returning within 2 min after distraction | P2 |
| Paid conversion | After AI insight / after limit screen | P3 |

---

## Target Market
| Segment | Size |
|---------|------|
| Korea — diagnosed + suspected ADHD adults | 120K diagnosed; 600K–1.2M estimated with suspected |
| English-speaking (US/CA/UK/AU) | 11.4M potential (4.4% adult prevalence in US) |

---

## Unit Economics
| MAU | Monthly server cost | BEP paid users needed |
|-----|--------------------|-----------------------|
| ~1,000 | $13–18/mo | Monthly: 37 / Annual: 55 |
| ~5,000 | $53–80/mo | — |

- **Target**: reach BEP within 6 months of launch
- **Conversion rate goal**: 2% at launch → 4% at 12 months → 7% at 18 months+

---

## Competitive Positioning
**The gap**: FocusFlight/Forest/TodoTimer serve people *already started*.
Own Ur Time serves the *can't-start-yet* user — no app addresses initiation + maintenance + recovery together.

| Feature | FocusFlight | Tiimo | Forest | Own Ur Time |
|---------|-------------|-------|--------|-------------|
| Initiation support | Boarding ritual (indirect) | None | None | **2-min + AI** |
| Distraction recovery | None | None | None | **Context card + 1-tap** |
| Ads | None | None | Yes | **Never** |
| Annual price | $23.99 | $59.99 | $9.99 | **₩33,000 (~$24)** |
