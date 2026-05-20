# stone_wall_normal

Normal maps are derived from the albedo — do not generate directly from a text prompt.

## Workflow
1. Generate `stone_wall_albedo.png` first
2. Upload to https://cpetry.github.io/NormalMap-Online/
3. Strength: 5–8 (deep block seam grooves, surface pitting, and impasto brushstroke relief)
4. Export as PNG

## Notes
- Higher strength than before — impasto brushstrokes add surface variation on top of the stone block relief
- Large block seams and mortar joints should produce strong normal displacement
- Brushstroke ridges should read as subtle micro-surface texture
- Crack edges and glyph etchings should read clearly
