# Project

A futuristic/medieval 3D multiplayer game built in **Godot 4** (GDScript). The world is an infinite 3D grid. Every location — player bases, combat arenas, markets, guild halls — occupies coordinates on this grid. Players navigate from inside their personal base, which travels through the grid and docks with other players' bases for co-op play. Combat is fast-paced melee/ranged (Dark Souls meets arena shooter). No classes — players build archetypes through weapons and skills. Professions have real mini-game skill checks that increase in complexity as you level.

Full roadmap: [docs/roadmap.md](docs/roadmap.md)
Setting & aesthetic: [docs/setting.md](docs/setting.md)
Mood board prompt guide: [docs/prompt_guide.md](docs/prompt_guide.md)

### Aesthetic in one sentence
Worn awe — ancient technology centuries old and showing it, cracked and tarnished but still glowing and functioning, nature reclaiming everything beautifully — *Breath of the Wild* meets *Moonlighter* meets *Horizon Zero Dawn*.

---

## Repo Layout

```
unsure/
├── docs/                    # Design docs, roadmap, mood board
└── swing/                   # Godot 4 project root
    ├── scenes/              # .tscn files
    ├── scripts/
    │   ├── autoloads/       # Singletons (GridCoord, Network)
    │   ├── base/            # Base classes (Location, NetworkProvider)
    │   └── networking/      # Provider implementations (OfflineNetworkProvider, future SteamNetworkProvider)
    ├── shaders/             # .gdshader files
    ├── materials/           # .tres material files
    ├── environments/        # .tres Environment + Sky resources
    ├── tests/
    │   └── unit/            # GUT test files (test_*.gd)
    └── addons/              # godot_ai + gut plugins (do not modify)
```

---

## Key Constants

| Constant | Value |
|---|---|
| Grid Unit | 10 × 10 × 4m (Godot units) — footprint of a studio apartment |
| Max Party Size | 4 |
| Base Starting Size | 1 × 1 grid unit |

---

## Current Phase

**Phase 0 — Architecture Foundation** — complete (mood board pending, user-driven)

**Phase 1 — The Base** — not started

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

## Multiplayer Authority Model

- **P2P via GodotSteam relay** — party, base movement, combat, character sync
- **Lightweight authoritative server** — economy writes, loot rolls, progression validation
- Current backend: `OfflineNetworkProvider` (single-player stub, all tests pass)
- To swap backend: `Network.use_provider(SteamNetworkProvider.new())` at startup
- GodotSteam not yet integrated (Phase 4)

---

## Tooling

The **Godot AI MCP plugin** is active in the editor. Use the MCP tools for all Godot editor operations (creating scenes, nodes, scripts, setting properties, managing materials, etc.) rather than editing `.tscn`/`.tres` files by hand. The plugin lives in `swing/addons/godot_ai/` — do not modify it.

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

### Keeping Docs Current

After completing any meaningful work, update the relevant docs before ending the session:

- **CLAUDE.md** — update `Current Phase` when a phase changes; add new conventions or constants as they are established
- **docs/roadmap.md** — move items to `[~]` when built, `[x]` only after user confirms; add sub-tasks as they are discovered
- If a design decision is made that overrides something in the roadmap, update the roadmap and note the reason

The goal is that any new session can read these two files and continue work without needing to re-derive context from the code or conversation history.
