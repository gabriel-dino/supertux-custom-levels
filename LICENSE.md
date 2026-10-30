# Licenses

This repository contains components under different terms. There is no single blanket license for all files.

| Component | License |
| --- | --- |
| Original level layouts, worldmap layouts, and English text | CC0-1.0 |
| Original generated creature/prop PNG artwork and its `.sprite` definitions in the level packs | CC0-1.0 |
| Transparent value-coin helpers under `assets/images/custom_worlds/` | CC0-1.0 |
| Portable Squirrel controllers under `assets/scripts/` | GPL-3.0-or-later |
| Worldmap tileset definitions under `assets/images/*.strf`, adapted from SuperTux road/terrain definitions | GPL-3.0-or-later |
| Bundled legacy Plant graphics in `lost_plant_world`, and referenced artwork/music provided by SuperTux | Their existing upstream licenses; see the pack’s `ASSET_NOTES.md` and `SUPERTUX-AUTHORS.txt` |

## Original levels and artwork

The project's original layouts, text, generated PNG artwork, and original sprite definitions are dedicated under **CC0 1.0 Universal**, to the extent the project holds rights in them. This continues the existing CC0 designation for layouts/text and Easter artwork and explicitly applies the same terms to the original IceSlime, Frostbound, and Harvest artwork.

Each pack includes `LICENSE-CC0-1.0.txt`. The [CC0 legal code](https://creativecommons.org/publicdomain/zero/1.0/legalcode) defines the dedication. This does not change rights in third-party content.

## Scripts and worldmap tilesets

The Squirrel controller adapts behavior from the project's GPL-covered custom C++ prototype. The worldmap tileset definitions adapt SuperTux tile/road mappings. They are distributed under the **GNU General Public License, version 3 or any later version**. Preserve their notices when redistributing or modifying them.

Each pack includes `LICENSE-GPL-3.0.txt`; the playable script source is included directly in packs that use it. SuperTux contributors retain their existing rights in material adapted from the game.

## Game resources and credits

Standard SuperTux artwork and music are referenced by path and supplied by the user's installed game. They are not covered by the CC0 dedication above. Their upstream credits and license terms remain unchanged.

Each pack's `ASSET_NOTES.md` identifies its original artwork. The historical creator credit “SuperTux Player” remains in the level and add-on metadata; the repository maintainer is Gabriel Dino.

The Lost Plant World preserves its original CC0 layout/text declaration. Its bundled legacy SuperTux Plant graphics are excluded from the CC0 dedication, and its sprite definition and controller adaptations use GPL-3.0-or-later. The reused project crown is CC0-1.0. The original creator credit “Lost Plant World contributors” is preserved.
