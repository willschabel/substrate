# Session Notes

*Updated at the end of each session. The session start hook surfaces this automatically. This is the first thing to read after CLAUDE.md.*

---

## Current State

**Active phase:** Phase 2 — First Combat Location (not yet started)

**Phase 0:** Complete
**Phase 1:** Complete
**Phase 2:** Not started — next up

---

## Last Session Summary

**Date:** 2026-05-26
**Type:** Product definition — no code changes

This session established the full product vision in `docs/vision.md` and overhauled `docs/roadmap.md` to match. No implementation work was done. The project is ready to begin Phase 2 in the next coding session.

**Key decisions made this session:**
- Game is entirely first person — no perspective switching
- No stamina system — deliberate play enforced by low TTK and weapon recovery animations
- Gear-based stats only — health pool, shield buffer, weapon damage; no character levelling
- HUD: health bar and shield bar only
- Extraction shooter death rules — lose everything carried on death
- Slot-based inventory with rarity point values; locations can have point entry/exit requirements
- Full lore locked: grid as cross-universe collection, AI corruption, players as AI creation, trickle-down abandonment, corrupted constructs as enemies
- Profession system designed in full: 10 ranks, proven proficiency, instacraft (2-rank buffer), blueprint system, deranking

**Documents updated:**
- `docs/vision.md` — created; full product definition
- `docs/roadmap.md` — overhauled to match vision
- `docs/lore_rules.md` — created; quick reference for lore constraints
- `CLAUDE.md` — updated to reflect accurate game description and added design protocol

---

## In Progress

Nothing in progress. Clean slate for Phase 2.

---

## Code Reference

**Style reference:** `substrate/scripts/autoloads/network.gd` — the cleanest example of conventions in this codebase. Section comments, clear delegation pattern, no logic in the facade. Follow this when unsure how to structure a new script.

**Key architectural notes:**
- `travel_system.gd` — dual-gate pattern: animation AND scene load must both complete before door opens. `_resolve_scene()` is the Phase 2 seam to fill.
- `base.gd` — NORTH door = main (location entry/exit). SOUTH/EAST/WEST = side doors (guest base docking, max 3 guests).
- `location.gd` — MISSION and PVP_ZONE types not yet added; Phase 2 adds them.
- `grid_coord.gd` — `to_world` and `to_world_floor` are currently identical; ask user whether this is intentional before touching either.

---

## Known Issues / Blockers

None.

---

## Decisions Pending

None — all Phase 2 prerequisites resolved this session.

---

*Template for future sessions:*
```
## Last Session Summary
Date: YYYY-MM-DD
Type: [implementation / design / bug fix / art]
Completed: [list items moved to [~] or [x]]
In progress: [anything left mid-flight]
Decisions made: [any design calls, with rationale]
Known issues: [anything broken or blocked]
```
