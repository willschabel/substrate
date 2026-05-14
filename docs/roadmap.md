# Game Roadmap

## Checkbox Convention

| Mark | Meaning |
|---|---|
| `[ ]` | Not started |
| `[~]` | Built — pending live test confirmation from user |
| `[x]` | Confirmed working by user in a live run |

## Concept Summary

A futuristic/medieval 3D multiplayer game built around an infinite 3D grid. Every location in the world — player bases, combat arenas, markets, guild halls — occupies coordinates on this grid. Players navigate the grid from inside their own personal base, which acts as a multidirectional elevator/hub that travels to objectives and docks with other players' bases for co-op play.

---

## Core Constants

| Constant | Value | Notes |
|---|---|---|
| Grid Unit | 10 × 10 × 4m (Godot units) | Footprint of a studio apartment, 4m ceiling |
| Max Party Size | 4 | One door per party member on host base |
| Base Starting Size | 1 × 1 grid unit | Can be upgraded |
| Safe Zones | Player markets, NPC markets | PvP/combat disabled |
| Dueling | Allowed in bases | Both players must accept |

---

## Multiplayer Authority Model

- **P2P via GodotSteam relay** — party, base movement, combat, character sync
- **Lightweight authoritative server** — economy writes, loot rolls, progression validation
- Goal: maximise client-side logic while closing obvious cheat vectors at the server boundary

---

## Phase 0 — Architecture Foundation
*Get the skeleton right before any features. No visible gameplay yet.*

- [x] `GridCoord` autoload — 3D integer coordinates, world↔grid conversion helpers
- [x] Scene conventions — `Location` base class with type, grid size, safe zone flag
- [x] Multiplayer authority layer — `NetworkProvider` base class, `OfflineNetworkProvider` stub, `Network` autoload facade
- [x] Grid visual — infinite white room with light blue grid lines (shader/environment, not geometry)
- [x] Refine player controller — dodge (Q), sprint (Shift), attack stubs (LMB/RMB)
- [x] GUT testing framework — install addon, create `res://tests/` directory, write tests for `GridCoord`
- [x] **Visual:** Mood board / style reference — lock the futuristic-medieval aesthetic before building anything permanent (AI tools for concepting)

---

## Phase 1 — The Base
*First thing the player sees. Sets the tone of the entire game.*

- [ ] Base scene (1 grid unit, 4 doors with open/closed state, placeholder interior)
- [ ] Navigation controller UI — select a grid coordinate, confirm travel
- [ ] Travel animation — base moves through grid, grid scrolls past windows
- [ ] Loading hook — travel animation masks async location load (everything else plugs into this seam)
- [ ] Lore camouflage system stub — other bases on the grid are invisible/incorporeal by design
- [ ] **Visual:** Base interior blockout — final geometry proportions, door placement, window placement (AI-assisted textures acceptable here, sets spatial expectations for all future base work)

---

## Phase 2 — First Combat Location
*Establish the combat feel. This is the most important phase for fun.*

- [ ] `Location` base class — declares grid size, type, safe zone flag, entry/exit points
- [ ] One static handcrafted combat arena (loads via travel system)
- [ ] Basic enemy AI — patrol, aggro, melee attack
- [ ] Melee combat — one weapon type, hit detection, stamina, hitstun. Get the feel right here.
- [ ] Ranged combat stub — one ranged weapon
- [ ] Loot drop + pickup
- [ ] Return travel back to base
- [ ] **Visual:** Hit feedback — impact effects, hitstun flash, basic enemy hurt animation (functional, not decorative; combat feel depends on these)
- [ ] **Visual:** Player character placeholder model — rigged capsule or simple humanoid, enough to support attack/dodge animations

---

## Phase 3 — First Profession (Smithing)
*Prove the profession system concept end-to-end.*

- [ ] Smithing workstation node (placeable in base)
- [ ] Level 1 mini-game — timing-based forging
- [ ] Crafted weapon has real stats, equippable
- [ ] Profession XP and level system (scaffold levels 1–5 so the complexity curve is designed-in from the start)
- [ ] Level 2–3 mini-game complexity increase (validates the "gets harder as you level" design)

---

## Phase 4 — Multiplayer
*Layer networking onto the already-working single-player loop.*

- [ ] GodotSteam integration — lobby, invite, join
- [ ] Party system — leader designation, 4-player max
- [ ] Base docking — joining player's base moves and slots adjacent to host, door connects visually
- [ ] Character sync — position, animation state, combat actions
- [ ] Hybrid authority — loot rolls and economy writes routed through lightweight server, not host client

---

## Phase 5 — Economy Skeleton

- [ ] Currency system
- [ ] Player-to-player trading (proximity-based, works in any non-combat zone)
- [ ] NPC market location (first non-combat location type)
- [ ] Loot rarity tiers (feeds into smithing material system)
- [ ] Basic player market location

---

## Phase 6 — Art & Polish Pass
*Do this before Steam release. Systems are locked — now make it look like the game it is.*

**Production assets (self-made + AI-assisted):**
- [ ] Final player character model + animations (Blender for rigging; AI tools for texture/concept reference)
- [ ] Final enemy models + animations
- [ ] Base interior — final textures, props, lighting
- [ ] Combat arena(s) — final environment art
- [ ] Weapon models
- [ ] VFX polish — combat hits, travel animation, door open/close, loot pickup
- [ ] UI art pass — navigation controller, inventory, trading, profession mini-game screens
- [ ] Audio — ambient, combat SFX, music pass
- [ ] Grid environment polish — the infinite white room is a hero visual, it should feel great

**Notes on AI tooling for art:**
- AI tools (Stable Diffusion, Midjourney, etc.) are well-suited for textures, concept reference, and 2D UI elements
- 3D character models still require manual rigging in Blender — AI can assist with textures/concepts but not the rig itself
- Lock the style reference from Phase 0 before generating assets so everything stays coherent

---

## Phase 7 — Expansion Layer
*Post-Polish, ongoing post-release content.*

- [ ] Base customization — add/remove room modules, cosmetics, window upgrades
- [ ] Additional professions (each with unique mini-game mechanic)
- [ ] Guild halls — multi-base docking location, member management
- [ ] Procedural location generator
- [ ] PvP / open-world locations with loot-on-kill
- [ ] Additional weapon archetypes
- [ ] Skill system depth — player-built class archetypes via weapon + skill combinations

---

## Key Decisions (Resolve Before Phase 4)

1. **GodotSteam vs raw Steamworks GDExtension** — GodotSteam is the community standard, worth committing to before any networking code is written
2. **Lightweight server stack** — a headless Godot instance on a $5/mo VPS is sufficient for economy authority until scale demands otherwise
3. **Static-first content policy** — all Phase 2 content should be static/handcrafted so combat feel can be tuned without generation complexity interfering

---

## Design Pillars

- **Movement matters** — fast-paced combat that also rewards patience and timing (Dark Souls meets arena shooter)
- **No classes** — players build their own archetype through weapon choice and skill investment
- **Professions have real depth** — skill checks get harder and more complex as you level, not just bigger numbers
- **Grid is the world** — every location, base, market, and guild hall is a coordinate; the grid is the connective tissue of everything
