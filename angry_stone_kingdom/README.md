# Angry Stone's Kingdom

Ten stages across Green Valley, Rocky Forest, Crystal Caves, Volcanic Mountains and the Stone Kingdom. Adapted from the custom campaign in `supertux-master` for **unmodified SuperTux 0.7.0**, using standard ScriptedObjects and Squirrel. Single-player is supported.

Install `angry_stone_kingdom.zip` through **Add-ons → Install from file** by dragging the ZIP onto the game window. Keep it zipped, enable the add-on, and select **Contrib Levels → User Contrib Levels → Angry Stone's Kingdom**. SuperTux 0.6.3 is unsupported; later versions have not been verified.

| Stage | Name |
| --- | --- |
| 1 | First Stone |
| 2 | Rolling Hills |
| 3 | Rocky Forest |
| 4 | Stone Bridge |
| 5 | Dark Cave |
| 6 | Falling Rocks |
| 7 | Lava Mountain |
| 8 | Ancient Ruins |
| 9 | Stone Fortress |
| 10 | The Stone King |

Angry Stones detect horizontal or vertical alignment, warn for 0.5 seconds, charge at 240 pixels per second for up to one second, and recover for 0.5 seconds. An impact stops the charge and remembers the blocked direction. Contact hurts Tux, including ordinary stomps. Fire does not defeat stones. Ice freezes a resting stone for three seconds; a butt-jump can break it.

The Stone King has six health icons and three phases. His four attacks are a rolling charge, a jump followed by two small ground rocks, falling rocks, and summoning up to two living guards. Each attack gives a 2.4-second recovery window. Stomp the crown during recovery; other crown landings bounce without damage. Hits give the king 1.2 seconds of protection. Defeating him removes summoned hazards, opens both gates, and shows the victory text. Walk through the castle exit to finish the stage. Enter through Contrib Levels for normal worldmap progress and the final completion flag.

## Portable adaptation

This recreates the campaign with the public scripting API, with these differences from its earlier C++ prototype:

- The boss uses the original 88-pixel stone artwork and matching hitbox, with a separate crown, rather than the prototype's 1.6× drawing, red eye overlay, rotation, and shrinking defeat effect. It flashes after damage and disappears after its defeat delay.
- Ground shockwaves use small stock rock sprites. Falling-rock and guard pools are bounded and reused.
- Tile and moving-platform contacts use the controller. Scripted stones do not participate in native enemy-to-enemy collisions or act as solid frozen blocks.
- Ice-projectile contacts are approximated by tracking player ice shots, as in the other portable worlds. Frozen stones flash instead of receiving the native ice overlay. Native projectile collisions elsewhere can differ.

The ten layouts, native enemies, collectibles, secrets, checkpoints, switches, platforms and exit triggers are retained. The map's ten stop tiles have separate, reciprocal road directions. Map progression uses the game's normal save system.

## Verification

See `validation/` in the development project for the current test reports. Tests use the official unmodified 0.7.0 AppImage in isolated user profiles, mounting the standalone ZIP. They check asset resolution, controller startup, safe spawns, directional attacks, wall stopping, contact damage, ice/fire behavior, the boss's attack cycle, recovery-only damage, hit protection, six real descending landings, and victory gates. Boss probes position Tux to exercise collisions; they are not a manual playthrough or a difficulty review.

## License

Original campaign levels, worldmap artwork and text retain **CC0-1.0** and the credit "Angry Stone's Kingdom contributors". Portable controller and tileset adaptation: **GPL-3.0-or-later**. Existing SuperTux graphics retain their upstream rights. See `ASSET_NOTES.md`, `SUPERTUX-AUTHORS.txt`, and the included license texts.
