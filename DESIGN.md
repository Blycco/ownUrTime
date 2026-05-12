---
version: alpha
name: OwnUrTime
description: ADHD-friendly productivity UI for iOS/macOS. Calm, low-distraction, high-clarity interface optimized for initiation, maintenance, and recovery.
colors:
  primary: "#2F6FEB"
  primary-hover: "#265ECC"
  primary-focus: "#4C84F5"
  on-primary: "#FFFFFF"
  canvas: "#F7F7F5"
  surface: "#FFFFFF"
  surface-soft: "#F1F3F5"
  ink: "#1F2328"
  ink-muted: "#5B6470"
  hairline: "#D8DEE4"
  success: "#1F8A4C"
  warning: "#B7791F"
  error: "#C53E3E"
  on-dark: "#FFFFFF"
typography:
  display-lg:
    fontFamily: "SF Pro Display, system-ui, -apple-system, sans-serif"
    fontSize: 34px
    fontWeight: 600
    lineHeight: 1.2
  title-md:
    fontFamily: "SF Pro Text, system-ui, -apple-system, sans-serif"
    fontSize: 20px
    fontWeight: 600
    lineHeight: 1.3
  body:
    fontFamily: "SF Pro Text, system-ui, -apple-system, sans-serif"
    fontSize: 16px
    fontWeight: 400
    lineHeight: 1.5
  body-sm:
    fontFamily: "SF Pro Text, system-ui, -apple-system, sans-serif"
    fontSize: 14px
    fontWeight: 400
    lineHeight: 1.45
  button:
    fontFamily: "SF Pro Text, system-ui, -apple-system, sans-serif"
    fontSize: 16px
    fontWeight: 600
    lineHeight: 1.2
  caption:
    fontFamily: "SF Pro Text, system-ui, -apple-system, sans-serif"
    fontSize: 13px
    fontWeight: 500
    lineHeight: 1.35
rounded:
  xs: 4px
  sm: 6px
  md: 8px
  lg: 12px
  xl: 16px
  pill: 9999px
spacing:
  xxs: 4px
  xs: 8px
  sm: 12px
  md: 16px
  lg: 24px
  xl: 32px
  section: 48px
components:
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    typography: "{typography.button}"
    rounded: "{rounded.md}"
    padding: "12px 16px"
    minHeight: 44px
  button-secondary:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.ink}"
    typography: "{typography.button}"
    rounded: "{rounded.md}"
    border: "1px solid {colors.hairline}"
    padding: "12px 16px"
    minHeight: 44px
  card:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.ink}"
    rounded: "{rounded.lg}"
    border: "1px solid {colors.hairline}"
    padding: "{spacing.lg}"
  input:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.ink}"
    typography: "{typography.body}"
    rounded: "{rounded.md}"
    border: "1px solid {colors.hairline}"
    padding: "10px 12px"
    minHeight: 44px
  status-success:
    backgroundColor: "{colors.surface-soft}"
    textColor: "{colors.success}"
    rounded: "{rounded.sm}"
  status-warning:
    backgroundColor: "{colors.surface-soft}"
    textColor: "{colors.warning}"
    rounded: "{rounded.sm}"
  status-error:
    backgroundColor: "{colors.surface-soft}"
    textColor: "{colors.error}"
    rounded: "{rounded.sm}"
---

## Overview
OwnUrTime prioritizes fast action over visual novelty. The interface should feel calm, predictable, and non-judgmental. Default surfaces are light, text contrast is high, and one primary action is emphasized per screen.

## Design Direction
- Apple-like restraint in chrome and typography.
- Cal-style practical card and form structure for productivity workflows.
- Linear-style strict component consistency for information hierarchy.

## ADHD UX Rules
- First meaningful action must be available in one tap.
- No shame framing or "failure" counters.
- Do not rely on color alone for meaning; pair with icon/text.
- Keep layouts stable to reduce cognitive switching cost.
- Motion should be brief and purposeful (150-250ms), no decorative loops.

## Color & Contrast
- Text and controls must meet WCAG AA contrast minimum.
- Use accent color primarily for CTA and focus states.
- Limit simultaneous accent colors on a single screen.

## Screen Patterns
- Task start: dominant micro-start CTA.
- Session: timer + distraction action always visible.
- Recovery: context restore card + one-tap resume.

## Accessibility
- Tap targets: minimum 44x44.
- Visible keyboard focus state required.
- Support dynamic text without clipping key controls.
