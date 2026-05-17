# Texture Workflow

How AI-generated textures are created, stored, and wired into the game.

---

## Toolchain

| Tool | Purpose |
|---|---|
| ComfyUI (local, Windows) | Texture generation via Stable Diffusion |
| Juggernaut XL | SDXL checkpoint for albedo generation |
| CHORD (Ubisoft, ComfyUI node) | Physically-consistent PBR map extraction — normal, roughness, height, metalness |
| Godot materials (`.tres`) | Material definition per surface type |
| `stochastic_surface.gdshader` | Optional stochastic tiling shader (exists, currently unused — revisit when textures are finalized) |

ComfyUI runs at `C:\ComfyUI_windows_portable` on a 3070 Ti.

---

## Prompt Files

Every texture has a corresponding prompt file at `docs/prompts/textures/<texture_name>.md`.

Structure:
```markdown
# <texture_name>

## Positive
<positive prompt>

## Negative
<negative prompt>

## Liked Seeds
<seed numbers that produced good results — one per line>
```

Key rules for texture prompts:
- Lead with `seamless tileable texture` or `seamless tileable 2d texture`
- End with `flat studio lighting, no perspective, no depth, texture map, albedo map, game asset, photorealistic`
- Keep accent colors (amber glow, teal circuit traces) described as `barely visible` / `very faint` — they are accents not dominant colors
- The base interior floor was originally precision-engineered: use `uniform cut stone slabs, straight joints` not `flagstone` or `irregular`
- Negative must always include: `saturated, colorful, vivid, glowing, blue stone, orange stone`
- Never put the surface type word in the negative (e.g. don't put `floor` in the negative for a floor prompt)

When a seed produces a result worth keeping, add it to `## Liked Seeds`.

---

## ComfyUI Workflow

Generation is split into two stages so you can review the texture before spending time on PBR map extraction.

### Stage 1 — Albedo Generation

Load the bundled example workflow:
```
C:\ComfyUI_windows_portable\ComfyUI\custom_nodes\comfyui-chord\example_workflows\chord_sdxl_t2i_image_to_material.json
```

**Disconnect** the wire between VAEDecode and ChordMaterialEstimation — Stage 2 runs separately.

Node graph:
```
CheckpointLoaderSimple (Juggernaut XL)
    ├─► SeamlessTile ──────────────────────────────────► KSampler ─► VAEDecode ─► Save Image (texture_image)
    ├─► CLIP Text Encode (Positive) ──────────────────► KSampler
    ├─► CLIP Text Encode (Negative) ──────────────────► KSampler
    └─► MakeCircularVAE ───────────────────────────────────────────► VAEDecode
Empty Latent Image ───────────────────────────────────► KSampler
```

KSampler settings:
- **Resolution**: 1024×1024 (final) / 768×768 (faster iteration while testing prompts)
- **Steps**: 30
- **CFG**: 7.0
- **Sampler**: dpmpp_2m
- **Scheduler**: karras
- **Denoise**: 1.0

**Performance note**: SDXL at 1024×1024 is much slower than SD 1.5. Each step takes 20–40 seconds on a 3070 Ti — 30 steps is 10–20 minutes. GPU maxed at 0% on first step is normal; it's loading the model. Use 768×768 while dialling in prompts, switch to 1024×1024 for keepers.

### Stage 2 — PBR Map Extraction (CHORD)

Once you're happy with the texture image, run Stage 2 using a `LoadImage` node pointing at the saved texture:

```
LoadImage (saved texture_image) ─► ChordMaterialEstimation ─┬─► Save Image (basecolor)
                                                              ├─► Save Image (normal)
                                                              ├─► ChordNormalToHeight ─► Save Image (height)
                                                              ├─► Save Image (roughness)
                                                              └─► Save Image (metalness)
ChordLoadModel (chord_v1.safetensors) ───────────────────────┘
```

CHORD generates all five maps in one coupled inference pass — they are physically consistent with each other. The `basecolor` output is a de-lit, refined version of your input; use it instead of the raw `texture_image` as the albedo in Godot.

---

## File Naming and Location

Each surface has 3 variants (a, b, c) generated from the same prompt with different seeds. The stochastic shader blends between them at runtime to eliminate visible tiling repetition.

CHORD outputs files with these names (ComfyUI appends `_00001_` automatically):

```
substrate/textures/base/<surface>/
├── a/
│   ├── texture_image_00001_.png   ← raw generated texture (keep for reference)
│   ├── basecolor_00001_.png       ← CHORD refined albedo — use this in Godot
│   ├── normal_00001_.png
│   ├── roughness_00001_.png
│   ├── height_00001_.png
│   └── metalness_00001_.png
├── b/
│   └── <same structure>
└── c/
    └── <same structure>
```

Drop new generations directly into `b/` or `c/` as-is — no renaming needed. When the stochastic shader is wired up the material will reference all three variants.

---

## Godot Material Setup

Each surface type has a `.tres` material at `substrate/materials/`.

| Material | File | Applied to |
|---|---|---|
| Stone floor | `stone_floor.tres` | Base interior floor |
| Stone wall | `stone_wall.tres` | Base interior walls (not yet created) |
| Stone trim | `stone_trim.tres` | Base interior trim (not yet created) |

### StandardMaterial3D — full PBR template

```
albedo_texture = <basecolor_00001_.png>
normal_enabled = true
normal_texture = <normal_00001_.png>
roughness = 1.0                        # Let the texture drive roughness fully
roughness_texture = <roughness_00001_.png>
roughness_texture_channel = 0
metallic = 0.0                         # Stone is not metallic
metallic_texture = <metalness_00001_.png>
metallic_texture_channel = 0
heightmap_enabled = true
heightmap_texture = <height_00001_.png>
heightmap_scale = 5.0                  # Start here; 2–4 subtle, 6–10 dramatic
heightmap_deep_parallax = true
heightmap_min_layers = 8
heightmap_max_layers = 32
uv1_scale = Vector3(8, 8, 8)           # Tune visually — smaller = larger stones
texture_repeat = true
```

### Applying to a mesh

Assign via `surface_material_override/0` on the MeshInstance3D, **not** `material_override`. If `material_override` is set it takes precedence over the surface slot — clear it to null first.

---

## Texture Checklist (per surface)

- [ ] Prompt file exists at `docs/prompts/textures/<name>_albedo.md`
- [ ] Stage 1: albedo generated, looks seamless, seed recorded if keeper
- [ ] Stage 2: CHORD run on approved texture — all 5 maps saved
- [ ] All files placed in `substrate/textures/base/<name>/`
- [ ] Material `.tres` updated with correct file paths and UV scale
- [ ] Material assigned to correct mesh in scene
- [ ] Game run to confirm appearance and parallax depth reads correctly

---

## Installation Notes

**CHORD git submodule**: ComfyUI Manager clones the repo but does not initialize the `chord/` submodule. If CHORD nodes show as missing after install, manually clone the submodule:
```
git clone https://github.com/ubisoft/ubisoft-laforge-chord.git "C:\ComfyUI_windows_portable\ComfyUI\custom_nodes\comfyui-chord\chord"
```
Then install CHORD's extra dependencies:
```
C:\ComfyUI_windows_portable\python_embeded\python.exe -m pip install "transformers==4.57.1" "tokenizers==0.22.1" typer tqdm
```

**CHORD model**: Gated on HuggingFace — requires a free account and accepting the Ubisoft ML license at `https://huggingface.co/Ubisoft/ubisoft-laforge-chord` before downloading. Place `chord_v1.safetensors` in `ComfyUI/models/checkpoints/`.

**ComfyUI cross-drive path error**: ComfyUI must be on the same drive as the output directory. If you see `ValueError: Paths don't have the same drive`, move ComfyUI or change the output path.

**Texture repetition on large surfaces**: Simple tiling repeats visibly at `uv1_scale` above ~12. `stochastic_surface.gdshader` exists to fix this — revisit once textures are finalized. If revisiting: sample normal map without rotation (only rotate albedo) to avoid lighting seams at hex cell boundaries.
