# Session Notes

*Updated at the end of each session. The session start hook surfaces this automatically. This is the first thing to read after CLAUDE.md.*

---

## Current State

**Active phase:** Phase 2 — First Combat Location (in progress)

**Phase 0:** Complete
**Phase 1:** Complete
**Phase 2:** In progress — pre-flight resolved, build underway

---

## Last Session Summary

**Date:** 2026-06-01
**Type:** Implementation — Phase 2 kickoff

Resolved the Phase 2 pre-flight gate with the user and locked all combat decisions into the docs, then began the Phase 2 build.

**Phase 2 pre-flight answers (locked):**
- **First weapon: shortsword** with directional, *Mordhau*-style melee — directional slash (LMB, angle from mouse movement just before/during the swing) + stab/thrust (RMB; faster, longer reach, less damage). Advanced techniques (accel, drag, feint, directional parry) are a later layer.
- **Ranged stub: pump shotgun** (basic fire, spread, range falloff); weapon switching between sword and shotgun.
- **First location: corrupted Harvesting Grounds** — agricultural constructs doing broken crop work; outdoor aesthetic (rolling terrain, half-buried ancient stones, vibrant nature, grid as glowing blue sky).
- **Dodge: removed entirely** — cut from game and docs. Spacing + commitment replace it.
- **Shield: no regen** — and health does not regen either; both are run resources until item/base restores them.
- **Death: instant cut back to base** (no fade/ragdoll); all carried items lost; base is respawn point.
- **Damage numbers: none** — feedback via VFX/hitstun/enemy reactions only.

**Documents updated this session:**
- `docs/vision.md` — directional melee + no-dodge locked; shield/health no-regen; no damage numbers; instant death sequence
- `docs/roadmap.md` — Phase 2 pre-flight marked RESOLVED with answers; combat items reworked (shortsword primary, shotgun stub); dodge references removed
- `CLAUDE.md` — input table updated (dodge removed, melee inputs clarified); Current Phase → Phase 2 in progress with locked decisions block
- `docs/session.md` — this update

---

## In Progress

**Phase 2 — combat vertical slice built, pending live feel test.**

Built this session (all marked `[~]` — need user confirmation):
- `Location` base class extended — `MISSION`/`PVP_ZONE` types, `pvp_active`/`is_mission`, `extraction_point_cap`, `locks_until_complete`, `get_entry_point()`. (12 tests)
- `Health` component (`scripts/combat/health.gd`) — health + shield, shield absorbs first, no regen, death + restore. Used by player and constructs. (17 tests)
- Player combat (`scripts/player.gd` + `scenes/player.tscn`) — dodge removed; weapon switching (1 sword / 2 shotgun); directional slash (LMB, angle read from recent mouse movement) + stab (RMB); `apply_damage` contract; instant respawn-at-spawn on death.
- `MeleeWeapon` (`scripts/combat/melee_weapon.gd`) — IDLE→WINDUP→ACTIVE→RECOVERY state machine, hitbox live only during ACTIVE, recovery lockout = commitment; tween-driven placeholder swing animation.
- `RangedWeapon` (`scripts/combat/ranged_weapon.gd`) — pump shotgun: hitscan pellet cone, distance falloff, pump cooldown.
- `Construct` enemy (`scripts/enemies/construct.gd` + `scenes/enemies/construct.tscn`) — patrol → chase → telegraphed strike; hurt flash + amber telegraph glow; collapses on death. Agricultural construct (Harvesting Grounds lore).
- HUD (`scenes/ui/hud.tscn`) — amber health bar + teal shield bar, no damage numbers.
- **`scenes/combat_sandbox.tscn`** — throwaway test arena (flat floor, player, HUD, 3 constructs). **Run this to feel-test combat.**

**Verification done:** 88/88 GUT tests pass; editor log clean; combat_sandbox runs with zero runtime errors (auto paths verified — patrol/perception/HUD-bind/weapon-init). Combat *interaction* paths (swinging, hitting, aggro, death) are untested-by-machine and are exactly what the live feel test must exercise.

**To test (controls):** WASD move, Shift sprint, Space jump, mouse look. `1` = shortsword, `2` = shotgun. LMB = slash (flick the mouse left/right/down just before clicking to pick the slash angle), RMB = stab (sword only). Esc frees the mouse.

**Tuning knobs** (all `@export`, edit live in the construct/weapon scenes): weapon damages/timings on `Shortsword` & `Shotgun`; construct `attack_*`, ranges, speeds, `Health.max_*`.

**Deferred until feel is confirmed** (roadmap gates on it): slot inventory + rarity points, extraction/loot drop, return-travel to base + base indexing, the handcrafted Harvesting Grounds art location, and the remaining hit-feedback VFX (player damage flash, weapon impact).

**Note on tooling:** new `class_name` scripts must be created via the MCP `filesystem_manage write_text` op (not a raw file write) or the headless GUT runner can't resolve the class. Test suite runs via `D:\Godot\Godot_v4.6.2-stable_mono_win64.exe` headless (MCP `test_run` doesn't see the `tests/unit/` subdir).

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
