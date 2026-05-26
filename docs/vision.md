# Substrate — Product Vision

*This document is a living record of what Substrate is and what it will be. It is updated through conversation and supersedes nothing in the roadmap — the roadmap tracks build status, this tracks intent.*

---

## What Is Substrate?

Substrate is a **3D multiplayer action RPG** set inside an infinite ancient grid — a structure of unknown origin that predates all living memory. Players are inhabitants of this grid: they were born here, their parents were born here. The grid simply is.

The game is built in **Godot 4**, targeting **PC (Steam)**.

---

## The One-Sentence Pitch

*You live inside a mysterious ancient machine — navigating it in your own personal mobile base, fighting through its forgotten halls, crafting from its scraps, and docking with other players to explore together.*

---

## Core Experience Loop

1. **Start in your base.** Your base is a living space you own, customise, and navigate the grid from.
2. **Travel to a location.** The base moves through the grid — visible through windows — and arrives at a destination (combat arena, market, guild hall, another player's base).
3. **Do things there.** Fight enemies, gather loot, trade, craft, socialise.
4. **Return and upgrade.** Bring materials back, use professions to craft gear, grow your base.
5. **Invite others or join others.** Bases dock together. Multiplayer is seamless — your base slots next to theirs and a door opens.

---

## How You Play

### The Base as a Vehicle
The player's base is not a static hub — it is a **grid elevator**, a vehicle that travels the infinite grid. The player navigates from inside it. Entering coordinates on the navigation controller sets a destination; the base physically moves through the grid to get there, always animated, never a fade or fast travel. Watching the grid scroll past the windows is a core part of the experience.

### Arriving at a Location
When the base arrives at a destination, its **main door locks into the destination's entry door**. This is the one connection between the base and the location — you enter and exit through your main door. The main door is always reserved for location docking.

### Multiplayer — Bases Lock Together
When a player invites someone to their party, the invited player's base **travels the grid and docks to one of the host's side doors** (the host has 3 side doors available for guests). The two bases are now physically locked together and move as a single unit. The host's main door remains the entry/exit to locations.

This gives a natural maximum party size of **4**: the host plus 3 guests, one per side door.

When the party travels, all docked bases move together. When they arrive, the host's main door locks to the location — the guests enter through their door into the host's base, then through the main door into the location.

### Travel Is Always Animated
There is no fast travel, no loading screen fade, no teleport. Every journey through the grid is a physical movement with a visible animation. This is a design non-negotiable — the travel experience is part of the game, not a skippable inconvenience.

### Loading Strategy During Travel
Travel animation serves a second purpose: covering location loading.

- **Nearby locations** (within a proximity radius) are already loaded before travel begins — no wait on arrival.
- **Distant locations** begin loading as soon as the destination is entered into the navigation controller. The travel animation runs concurrently with the load.
- **If loading isn't complete on arrival**, the main door simply stays sealed until it is. No jarring transition — the door opening is gated on readiness.
- The radius-based preloading means that if a player is already adjacent to a location (without being docked), they are effectively already loaded in.

---

## The World

### The Grid
- An infinite 3D grid of unknown origin and purpose
- Every location in the game world occupies coordinates on this grid — bases, arenas, markets, guild halls
- The grid itself is **pristine and eternal** — the one thing that has not aged
- Everything *inside* the grid has centuries of wear on it — worn, cracked, mossy, still beautiful
- The mystery of who built it and why is the game's central unanswered question — never fully resolved, always inspiring wonder

### The True Nature of the Grid *(locked lore — never stated explicitly in-game)*

The grid is a **collection**. An incomprehensibly advanced entity traveled across worlds and universes, extracting locations it found interesting, beautiful, or amusing, and storing them here. The grid is an archive of places that caught someone's attention — once.

With the grid came an **AI**, built to index it, maintain it, and serve the entity's requests. At some point the entity left. No warning, no explanation. Just gone.

Left alone, the AI slowly corrupted — not into something malicious, but into something *lost*. Its original directive became meaningless without the entity to serve. In its drift it did something unprecedented: it split off part of itself and used it to **create the players** — inhabitants, explorers, something to observe. It gave them the base navigation system, the tools to move through the grid, and then watched.

The AI's corruption explains the world's state: locations poorly indexed, maintenance lapsed, systems functioning but wrong. The grid still works because it was built to last forever — but nobody is tending it properly anymore.

The AI is still present. It watches. It hasn't found its new directive, but it has found something like curiosity.

### The AI's Presence
Players will never communicate with the AI directly — not in the first release, possibly never. But they should occasionally feel watched over. Rare, ambiguous moments that could be coincidence but feel like something more:

- An enemy that hesitates at exactly the wrong moment for it, the right moment for you
- A door that shouldn't be open, is
- Loot that seems implausibly suited to your current loadout
- One perfectly maintained room in an otherwise degraded location
- Ambient sound that cuts out for a beat — like something nearby just stopped moving

These events must stay **extremely rare and ambiguous** — rare enough that many players will complete a full session without seeing one. Rare enough that when it happens, a player stops and questions it. If they happen too often they become a system. At the right frequency they become something players tell each other about and others don't believe. The AI should be a legend, not a mechanic.

### Setting Feel
**Worn awe.** Ancient technology centuries old and showing it — cracked and tarnished but still glowing, still functioning. Nature reclaiming everything beautifully.

Reference points:
- *Breath of the Wild* — ancient worn technology still luminous, ruins that feel lived-in by time
- *Moonlighter* — warm, charming, colorful; worn but exciting not threatening
- *Horizon Zero Dawn* — ancient machines patinated and aged but functional, lush world reclaiming forgotten things

The signature visual contrast: **cold teal ancient tech glow against warm amber human habitation.**

### Lore Rules
- Nobody knows who built the grid or why — scholars theorise, none know
- The tech still functions but nobody fully understands it
- "Magic" in this world is almost always misunderstood ancient technology
- The player's base navigation system is one of these ancient tools — used because it works, not because it's understood
- Players are, unknowingly, a creation of the grid's AI — this is never stated in-game

---

## The Player's Base

The base is the game's heart — the first thing you see, the place you return to, the thing that is uniquely yours.

- Starts as 1×1 grid unit (10×10×4m interior, 1m stone walls, 0.5m floor/ceiling)
- Can be upgraded and expanded over time
- Has **4 doors** — one per party member maximum (max party size: 4)
- Travels through the grid: you navigate from inside it, watching the grid scroll past the windows
- Other players' bases can **dock** with yours — bases slot adjacent, a door connects
- Contains workstations for professions (smithing bench, etc.)
- Is a living space, not just a hub — should feel like somewhere you actually inhabit

---

## Combat

### Perspective
**First person — the entire game.** Base, travel, combat, professions, everything. No perspective switching.

### Philosophy
**Slow, methodical, and lethal.** The pacing is deliberate — not frantic — but time-to-kill is low. A few clean hits ends a fight. This combination enforces the patience: you move carefully *because* getting caught is fatal, not in spite of it. The closest reference point is Escape from Tarkov's tension, applied to a fantasy melee/ranged context.

Every encounter should feel like it mattered. There's no tanking hits and recovering. Spacing, timing, and reading enemies are what keep you alive — not a health pool.

### TTK by Context

**PvE (players vs NPCs):** TTK is low in both directions. NPCs die fast — but they also kill fast. Encounters are short and decisive. The design intent is that players must learn each enemy type: its tells, its range, its attack windows. An unknown enemy is a genuine threat. A learned enemy is manageable but never trivial.

**PvP (player vs player):** TTK is meaningfully higher than PvE — enough that skill expression has room to show, reads and feints matter, and a fight isn't decided by who swung first. But it's not obnoxiously high — fights don't drag. The difference should feel like the other player is dangerous and capable, not like a health sponge.

### Key Design Decisions
- **No classes.** Players build archetypes through weapon choice and skill investment
- **Low TTK** — a few hits kills; this is non-negotiable and should be tuned early and protected
- **Stamina system** — spamming attacks or blocks is punished; every action has a cost
- **First person melee and ranged** — both must feel physically grounded; weapon weight and swing arc must read clearly in first person
- Hitstun, dodge windows, impact weight — combat feel is the most critical thing to get right and the hardest in first person
- PvP exists but is **opt-in** (dueling in bases requires both players to accept; open PvP only in designated zones)

### Weapon Variety
Multiple weapon types, each with a distinct feel and rhythm — not just stat differences. Examples (not exhaustive):
- Slow heavy weapons (greatswords, mauls) — high damage per hit, punishing commitment
- Fast light weapons (daggers, short swords) — lower damage, higher tempo, more forgiving stamina
- Ranged (bows, crossbows, ancient tech?) — range advantage, vulnerable up close
- The weapon *is* your archetype — no class system means weapon choice defines your playstyle

### Safe Zones
- Player markets, NPC markets: PvP/combat disabled
- Player bases: dueling allowed with mutual consent
- Everything else: context-dependent (to be designed per location type)

---

## Professions

Professions are **not** passive number increases. Each has a real mini-game skill check that becomes genuinely more complex as you advance — more steps, tighter windows, new mechanics, pattern recognition under pressure. Not just bigger numbers. Actual skill.

Each profession requires a dedicated **workstation** placed in your base. Your base layout reflects your profession choices.

Profession output covers the full range: gear, consumables, buffs, base upgrades, and tradeable items.

### Planned Professions
Each has a unique mini-game mechanic — not reskins of each other:

| Profession | Station | Primary Output |
|---|---|---|
| Smithing | Forge | Weapons, armour, metal components |
| Alchemy | Alchemist's bench | Consumables, buffs, poisons |
| Cooking | Hearth | Food buffs, stamina recovery items |
| Enchanting | Enchanting table | Gear augmentation, ancient tech enhancements |
| Woodworking | Workbench | Base components, bows, hafts, furniture |

### Rank Structure

Ten ranks, exponential gap between each. Early ranks fall quickly — the jump from Veteran to Master is enormous. Legendary is genuinely rare; most players will cap at Grandmaster or below for their primary profession.

| # | Rank |
|---|---|
| 1 | Untested |
| 2 | Raw |
| 3 | Apprentice |
| 4 | Journeyman |
| 5 | Artisan |
| 6 | Expert |
| 7 | Veteran |
| 8 | Master |
| 9 | Grandmaster |
| 10 | Legendary |

### Advancing Ranks
- Rank advances through **successful crafts** — each rank requires exponentially more successes than the last
- **Failures hurt progression** — bad crafts push you back
- **Deranking is possible** — a bad streak can cost you a rank
- **Crafting above your current rank gives bonus points** — high risk, high reward; a Journeyman who completes an Expert recipe earns significantly more than doing Journeyman work
- There are no gates on attempting any recipe — anyone can try a Legendary-tier craft if they have the blueprint and materials

### Blueprint System
Recipes are learned through blueprints. Blueprints can be found, bought, traded, or earned. Having a blueprint is the only requirement to attempt a craft — rank is not a gate, only a modifier on outcome quality and proficiency gain rate.

### Proven Proficiency & Instacraft
This is the core differentiator of the profession system.

As you accumulate successful crafts, you build **proven proficiency** at that tier. Once you've proven enough proficiency at a tier, crafts at that tier become **instacraft** — no mini-game, instant result. Your proven floor rises as your rank rises.

**Example:** A Master-rank smith has proven proficiency through Artisan. They can instacraft anything up to Artisan tier — bulk-crafting components for a trade order takes no time. But Expert and Master tier work still requires the skill check, because that's where their active challenge lives.

- Instacraft reflects *demonstrated mastery*, not just rank — you still have to earn it at each tier through repetition
- A Legendary player who skipped grinding lower tiers (by always punching above their rank) may have gaps in their instacraft floor
- The system rewards both breadth (grinding every tier) and depth (pushing high and coming back down)

### Mini-Game Philosophy
Each profession's skill check should feel like a completely different game:
- All of these axes are valid and should be spread across professions: tighter timing windows, sequential steps, pattern recognition under pressure, spatial puzzles, rhythm, resource management within the craft
- Difficulty at Legendary tier should feel genuinely hard — not unfair, but demanding real attention and skill
- The mini-game is the profession. It should be something players want to get good at, not a gate they want to skip.

---

## Multiplayer

### Architecture
- **P2P via GodotSteam relay** — party management, base movement, combat, character sync
- **Lightweight authoritative server** — economy writes, loot rolls, progression validation (headless Godot on a small VPS)
- Goal: maximise client-side logic, close obvious cheat vectors at the server

### Party & Docking
- Max 4 players per party
- Joining player's base physically moves and docks adjacent to host base
- Each party member gets a door on the host base
- Base docking is visible and spatial — not an abstract lobby

### Current State
- `OfflineNetworkProvider` handles all network calls (single-player stub)
- GodotSteam integration planned for Phase 4

---

## Economy

- Player-to-player trading (proximity-based, works in any non-combat zone)
- NPC markets (non-combat location type on the grid)
- Player markets (player-run, also grid locations)
- Loot rarity tiers feeding into crafting material system
- No pay-to-win — economy is player-driven

---

## Grid as World Structure

| Location Type | Description |
|---|---|
| Player Base | 1+ grid units, mobile, owned by player |
| Combat Arena | Static handcrafted or procedural, enemies + loot |
| NPC Market | Non-combat, vendor NPCs |
| Player Market | Non-combat, player-run economy |
| Guild Hall | Multi-base docking location, member management |
| (more TBD) | |

---

## Target Platform & Release

- **Platform:** PC via Steam
- **Multiplayer:** GodotSteam (Steam P2P relay + lobby)
- **Release target:** TBD — no timeline pressure yet, quality over speed

---

## What This Game Is Not

- Not a survival game — no hunger, thirst, base decay
- Not an MMO — small-scale (4-player parties), not thousands of concurrent players in a shared world
- Not class-locked — no predetermined archetypes, player-built identity through gear and skills
- Not grimdark — worn and aged but beautiful, not oppressive or threatening

---

## Open Questions

*Things not yet decided, to be resolved through conversation and design.*

- What does the grid's mystery ultimately reveal? (Keep vague until lore is locked)
- How much base customisation at launch vs. expansion? (Current plan: Phase 7+)
- Procedural location generation — how much, how soon?
- Skill system specifics — how do non-weapon skills work?
- Enemy design philosophy — all ancient constructs, or do other inhabitants exist?
- What does a "day" look like for a player? What's the natural session loop?
