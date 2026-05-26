# Project

A first-person 3D multiplayer extraction RPG built in **Godot 4** (GDScript). The world is an infinite 3D grid of unknown origin. Players navigate from inside their personal mobile base, which travels the grid and docks with other players' bases for co-op play. Combat is slow, methodical, and lethal — first person, gear-based stats, no stamina system. Death means losing everything you brought in. Professions have real mini-game skill checks that grow in complexity as you rank up, with a proven proficiency system that unlocks instacraft for mastered tiers.

Full vision & product definition: [docs/vision.md](docs/vision.md)
Full roadmap: [docs/roadmap.md](docs/roadmap.md)
Lore constraints: [docs/lore_rules.md](docs/lore_rules.md)
Current session state: [docs/session.md](docs/session.md)
Setting & aesthetic: [docs/setting.md](docs/setting.md)

### Aesthetic in one sentence
Worn awe — ancient technology centuries old and showing it, cracked and tarnished but still glowing and functioning, nature reclaiming everything beautifully — *Breath of the Wild* meets *Moonlighter* meets *Horizon Zero Dawn*.

---

## Repo Layout

```
substrate/  (repo root)
├── docs/                    # Design docs, roadmap, vision, lore rules, session notes
└── substrate/               # Godot 4 project root
    ├── scenes/              # .tscn files
    ├── scripts/
    │   ├── autoloads/       # Singletons (GridCoord, Network)
    │   ├── base/            # Base classes (Location, NetworkProvider)
    │   └── networking/      # Provider implementations (OfflineNetworkProvider, future SteamNetworkProvider)
    ├── shaders/             # .gdshader files
    ├── materials/           # .tres material files
    ├── environments/        # .tres Environment + Sky resources
    ├── tests/               # GUT test files (test_*.gd)
    └── addons/              # godot_ai + gut plugins (do not modify)
```

---

## Key Constants

| Constant | Value |
|---|---|
| Grid Unit | 12 × 12 × 5m (Godot units) — 10 × 10 × 4m interior + 1m stone walls + 0.5m floor/ceiling |
| Max Party Size | 4 (host + 3 guests, one side door each) |
| Base Starting Size | 1 × 1 grid unit |

---

## Current Phase

**Phase 0 — Architecture Foundation** — complete
**Phase 1 — The Base** — complete
**Phase 2 — First Combat Location** — next

---

## Registered Autoloads

| Singleton | Path | Purpose |
|---|---|---|
| `GridCoord` | `scripts/autoloads/grid_coord.gd` | World↔grid coordinate conversion, adjacency, cell size |
| `Network` | `scripts/autoloads/network.gd` | Single entry point for all network ops — never call a provider directly |

## Scene & Script Conventions

- Every location scene extends `Location` and sets `location_type`, `grid_size`, `grid_position`
- Player controller: `scenes/player.tscn` + `scripts/player.gd`
- Main scene (dev sandbox): `scenes/main.tscn`
- Startup scene: `res://scenes/main.tscn`

### Input Actions

| Action | Key | Status |
|---|---|---|
| `move_forward` | W | active |
| `move_back` | S | active |
| `move_left` | A | active |
| `move_right` | D | active |
| `ui_accept` (jump) | Space | active |
| `sprint` | Shift | active |
| `dodge` | Q | active |
| `attack_primary` | LMB | stub (Phase 2) |
| `attack_secondary` | RMB | stub (Phase 2) |
| `nav_open` | Tab | toggle navigation controller UI |

## Multiplayer Authority Model

- **P2P via GodotSteam relay** — party, base movement, combat, character sync
- **Lightweight authoritative server** — economy writes, loot rolls, progression validation
- Current backend: `OfflineNetworkProvider` (single-player stub, all tests pass)
- To swap backend: `Network.use_provider(SteamNetworkProvider.new())` at startup
- GodotSteam not yet integrated (Phase 4)

---

## Tooling

The **Godot AI MCP plugin** is active in the editor. Use the MCP tools for all Godot editor operations (creating scenes, nodes, scripts, setting properties, managing materials, etc.) rather than editing `.tscn`/`.tres` files by hand. The plugin lives in `substrate/addons/godot_ai/` — do not modify it.

Always check `editor_state` at the start of a session to confirm the editor is ready before issuing editor commands.

After every implementation — scripts, shaders, or scene changes — always run both log checks before declaring work ready for testing:

```
logs_read(source="editor")   # parse errors, type errors, shader compile failures
logs_read(source="game")     # runtime errors (only meaningful after project_run)
```

If `source="editor"` returns any errors, fix them before asking the user to test. Do not mark a roadmap item `[~]` until both checks are clean. Note: shader compilation errors only surface at runtime, so `source="game"` after a `project_run` is the safety net for those.

The `editor` log buffer can be stale — it persists old errors until Godot re-evaluates the file. If the log shows errors but the Godot console is clean, trust the console. When in doubt, trigger a reimport of the affected file to force re-evaluation.

---

## Working Agreement

### Roadmap Checkbox Convention

| Mark | Meaning |
|---|---|
| `[ ]` | Not started |
| `[~]` | Built — pending live test confirmation from user |
| `[x]` | Confirmed working by user in a live run |

**Never mark an item `[x]` without the user explicitly confirming it works.** When work is done, set `[~]` and ask the user to test. Only upgrade to `[x]` after they confirm. Skip the live-test gate only for items that are purely structural and have no observable runtime behaviour (e.g. a doc update, a constants file with no logic).

### Unit Tests

All game logic must have unit tests written alongside it using **GUT** (Godot Unit Test framework). GUT is installed at `res://addons/gut/`.

- Test files live in `res://tests/` and are named `test_<subject>.gd`
- Every test file extends `GutTest`
- Write or update tests in the same session as the code they cover — do not defer
- Pure autoloads, base classes, and utility functions must be tested; scene-level glue code and pure visual behaviour need not be
- **After writing or updating tests, always run them via `test_run` before asking the user to test.** Fix any failures before handing off. Do not mark a roadmap item `[~]` if tests are failing. Note: `test_run` only discovers files directly in `res://tests/` — subdirectories require running via the GUT panel in the editor.

### Keeping Docs Current

After completing any meaningful work, update the relevant docs before ending the session:

- **CLAUDE.md** — update `Current Phase` when a phase changes; add new conventions or constants as they are established
- **docs/roadmap.md** — move items to `[~]` when built, `[x]` only after user confirms; add sub-tasks as they are discovered
- **docs/session.md** — update at the end of every session with what was done, what's in progress, and any decisions made
- If a design decision is made that overrides something in the vision or roadmap, update both and note the reason

The goal is that any new session can read CLAUDE.md + docs/session.md and be fully oriented without re-deriving context from code or conversation history.

---

## Design Protocol

### When to Ask vs. When to Proceed

**If the user waves off pre-flight questions and says to just start building:** note which questions were skipped in docs/session.md, state the assumption made for each one explicitly in your first message, and mark every place that assumption affects code with `# ASSUMPTION: <what was assumed>`. The user can then correct assumptions without hunting through the codebase.

**Always ask before proceeding if:**
- A design detail affects how a system is *built* and isn't specified in docs/vision.md
- Something contradicts a locked decision (marked `*(locked)*` in vision.md)
- Adding any world content — enemies, locations, lore details, NPC dialogue — check docs/lore_rules.md first and ask if anything is ambiguous
- A task would require more than one phase of work to complete

**Proceed with a reasonable call and note it if:**
- The decision is purely cosmetic, stylistic, or easily reversible
- The detail is implementation-level (variable names, file structure, minor UI layout)
- The vision doc gives enough direction to infer the right answer

**Never:**
- Invent lore, world details, or enemy designs without checking docs/lore_rules.md
- Reopen a decision marked `*(locked)*` in docs/vision.md
- Mark a roadmap item `[x]` without explicit user confirmation
- Skip tests for any system with logic

### Implementation Loop

For every feature or system:
1. Confirm design is specified in vision/roadmap — ask if anything is missing
2. Write code + tests together
3. Run `test_run` — fix failures before continuing
4. Run `logs_read(source="editor")` — fix errors before continuing
5. Run project and `logs_read(source="game")` for runtime check
6. Mark roadmap item `[~]`, update docs/session.md, ask user to test
7. On user confirmation: mark `[x]`, update CLAUDE.md if phase changed
