# Game Roadmap

## Checkbox Convention

| Mark | Meaning |
|---|---|
| `[ ]` | Not started |
| `[~]` | Built — pending live test confirmation from user |
| `[x]` | Confirmed working by user in a live run |

## Concept Summary

A first-person 3D multiplayer extraction RPG set inside an infinite ancient grid. Every location — player bases, combat locations, markets, guild halls — occupies coordinates on this grid. Players navigate from inside their own personal mobile base, which travels the grid and docks with other players' bases for co-op play. Death means losing everything you brought in. The grid is the world, the base is the vault, and exploration is how you build knowledge.

---

## Core Constants

| Constant | Value | Notes |
|---|---|---|
| Grid Unit | 12 × 12 × 5m (Godot units) | 10 × 10 × 4m interior + 1m stone walls each side + 0.5m floor/ceiling |
| Max Party Size | 4 | Host main door for location entry; 3 side doors for guest bases |
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

- [x] Base scene (1 grid unit, 4 doors with open/closed state, placeholder interior)
- [x] Navigation controller UI — select a grid coordinate, confirm travel
- [x] Travel animation — base moves through grid, grid scrolls past windows
- [x] Loading hook — travel animation masks async location load (everything else plugs into this seam)
- [x] Lore camouflage system stub — other bases on the grid are invisible/incorporeal by design
- [x] **Visual:** Base interior blockout — final geometry proportions, door placement, window placement (AI-assisted textures acceptable here, sets spatial expectations for all future base work)

---

## Phase 2 — First Combat Location
*Establish the combat feel. This is the most important phase for fun.*

- [ ] `Location` base class — extend Phase 0 base with entry/exit door binding, location type declaration, per-location rule flags (PvP on/off, mission vs open world)
- [ ] One static handcrafted open-world location — thematically coherent constructs reflecting what the location once was (see vision doc enemy lore)
- [ ] Basic enemy AI — patrol, aggro, melee attack; enemies are corrupted maintenance constructs, not generic monsters
- [ ] First-person viewmodel — arms and weapon only; no third-person body needed
- [ ] Melee combat — one weapon type, hit detection, stamina, hitstun. Slow and methodical. Get the feel right here.
- [ ] Ranged combat stub — one ranged weapon
- [ ] Extraction rules — losing all carried items on death; loot drop + pickup
- [ ] Return travel back to base
- [ ] Base indexing — location visited is recorded with coordinates, type, and observed conditions; foundation for the player's personal grid atlas
- [ ] **Visual:** Hit feedback — impact effects, hitstun flash, basic enemy hurt animation (functional, not decorative; combat feel depends on these)

---

## Phase 3 — First Profession (Smithing)
*Prove the profession system concept end-to-end — ranks, proven proficiency, instacraft, blueprints.*

- [ ] Smithing workstation node (placeable in base)
- [ ] Blueprint system — blueprints unlock recipes; no rank gate on attempting a craft, only on outcome and proficiency gain rate
- [ ] 10-rank progression system (Untested → Raw → Apprentice → Journeyman → Artisan → Expert → Veteran → Master → Grandmaster → Legendary) with exponential success requirements per rank
- [ ] Failure mechanic — failed crafts push back progression; deranking possible on a bad streak
- [ ] Above-rank bonus — crafting higher than current rank earns more proficiency points
- [ ] Proven proficiency tracker — advances sequentially from Untested one rank at a time regardless of current rank
- [ ] Instacraft system — unlocks all tiers up to 2 ranks below proven proficiency rank
- [ ] Rank 1–3 mini-games (Untested/Raw/Apprentice) — timing-based forging, establishes smithing's core mechanic
- [ ] Rank 4–6 mini-games (Journeyman/Artisan/Expert) — complexity increase; more steps, tighter windows
- [ ] Crafted weapons have real stats and are equippable

---

## Phase 4 — Multiplayer
*Layer networking onto the already-working single-player loop.*

- [ ] GodotSteam integration — lobby, invite, join
- [ ] Party system — leader designation, 4-player max
- [ ] Base docking — joining player's base moves and slots adjacent to host, side door connects visually; host main door used for location entry
- [ ] Character sync — position, animation state, combat actions
- [ ] Hybrid authority — loot rolls and economy writes routed through lightweight server, not host client

---

## Phase 5 — Economy & Objectives Skeleton

- [ ] Currency system
- [ ] Loot rarity tiers (feeds into crafting material system)
- [ ] Player-to-player trading (proximity-based, works in any non-combat zone)
- [ ] NPC market location (first non-combat location type) — safe zone, vendor NPCs
- [ ] NPC quest system — retrieve, deliver, clear objectives; optional direction for players who want it
- [ ] Basic player market location — safe zone, player-run stalls
- [ ] Player contracts — post commissions for crafted items, material bounties, retrieval jobs at player markets
- [ ] Base indexing UI — player can review their indexed grid atlas, filter by location type

---

## Phase 6 — Remaining Professions
*Each profession needs a unique mini-game mechanic — not a smithing reskin.*

- [ ] Alchemy — consumables, buffs, poisons
- [ ] Cooking — food buffs, stamina recovery items
- [ ] Enchanting — gear augmentation, ancient tech enhancements
- [ ] Woodworking — base components, bows, hafts, furniture
- [ ] Rank 7–10 mini-games for smithing (Veteran/Master/Grandmaster/Legendary) — peak complexity

---

## Phase 7 — Art & Polish Pass
*Do this before Steam release. Systems are locked — now make it look like the game it is.*

**Production assets (self-made + AI-assisted):**
- [ ] Final first-person viewmodel — arms, hands, weapon animations (attack, block, dodge, idle)
- [ ] Final enemy models + animations — per-location thematic constructs, not generic enemies
- [ ] Base interior — final textures, props, lighting
- [ ] Combat location(s) — final environment art
- [ ] Weapon models
- [ ] VFX polish — combat hits, travel animation, door open/close, loot pickup
- [ ] UI art pass — navigation controller, inventory, trading, profession mini-game screens, grid atlas
- [ ] Audio — ambient, combat SFX, music pass
- [ ] Grid environment polish — the infinite white room is a hero visual, it should feel great

**Notes on AI tooling for art:**
- AI tools (Stable Diffusion, Midjourney, etc.) are well-suited for textures, concept reference, and 2D UI elements
- 3D character assets still require manual rigging in Blender — AI can assist with textures/concepts but not the rig itself
- Lock the style reference from Phase 0 before generating assets so everything stays coherent

---

## Phase 8 — PvP & Expansion Layer
*Core game content built post-polish. PvP zones are a primary playstyle path, not optional extras.*

- [ ] PvP zones — grid locations where players are threats; high-risk high-reward; loot-on-kill
- [ ] Mission location type — structured objectives, can lock players in until completion conditions met; per-location time cycles and rules
- [ ] Base customization — add/remove room modules, cosmetics, window upgrades
- [ ] Guild halls — multi-base docking location, member management
- [ ] Procedural location generator
- [ ] Additional weapon archetypes
- [ ] Skill system depth — player-built archetypes via weapon + skill combinations

---

## Key Decisions (Resolve Before Phase 4)

1. **GodotSteam vs raw Steamworks GDExtension** — GodotSteam is the community standard, worth committing to before any networking code is written
2. **Lightweight server stack** — a headless Godot instance on a $5/mo VPS is sufficient for economy authority until scale demands otherwise
3. **Static-first content policy** — all Phase 2 content should be static/handcrafted so combat feel can be tuned without generation complexity interfering

---

## Design Pillars

- **Slow, methodical, lethal** — first-person combat where patience is enforced by consequence; low PvE TTK in both directions, higher PvP TTK to allow skill expression
- **No classes** — players build their own archetype through weapon choice and skill investment
- **Professions have real depth** — skill checks get genuinely harder as you rank up; proven proficiency earns instacraft, not rank alone
- **Grid is the world** — every location, base, market, and guild hall is a coordinate; exploration builds knowledge, and knowledge is the meta-game
- **The base is the vault** — extraction rules make every run a real decision; what you bring in, you risk
