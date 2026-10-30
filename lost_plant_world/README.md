# The Lost Plant World

Ten stages through forgotten gardens, poisonous paths, root caves, an overgrown temple, greenhouses, and Plant King's fortress. Imported from Gabriel Dino's custom SuperTux installation and adapted for **regular SuperTux 0.7.0**, without a custom engine.

Install `lost_plant_world.zip` through **Add-ons → Install from file** by dragging the ZIP onto the game window. Keep it zipped. Select **Contrib Levels → User Contrib Levels → The Lost Plant World**. SuperTux 0.6.3 is unsupported; newer versions have not been verified. Single-player is supported.

Plants sleep until Tux approaches from the front, play the six-frame wake animation, and patrol at 80 pixels per second. Ordinary stomps do not defeat them. Fire defeats Plants, ice temporarily freezes them, and butt-jumps can defeat them.

Plant King takes six stomps, with 1.2 seconds of protection after each hit. Its three phases retain patrols, one-second attack warnings, up to six summoned Plants, root darts, and temporary emerging roots. The last phase increases patrol speed and shortens attack intervals. The crown and six health icons identify the boss. Defeating it opens RoyalGate, displays the original victory text, and finishes the stage; the worldmap's final-stage script records completion.

This is a Squirrel adaptation of the original C++ gameplay. The boss uses the normal-size Plant artwork and hitbox with a separate crown, rather than the custom engine's double-size drawing. Root/dart contacts and movement use the portable controller, with a reusable pool of six darts and one root; projectile and damage interactions can differ from the custom engine. Freeze and hit protection use flashing instead of tinting or an ice overlay. Invincibility and stone-contact damage from the custom engine are not reproduced; use stomps against the boss. Native checkpoints, collectibles, and worldmap progress remain available.

The source installation is unchanged. The original authoring README and custom-engine test claims are retained only in the local development backup, because those tests do not establish compatibility of this adaptation.

## License

Original level/worldmap layouts and text: **CC0-1.0**, preserving the original files' declaration and author credit, “Lost Plant World contributors.”

Portable controller and adapted worldmap/sprite definitions: **GPL-3.0-or-later**. The controller adapts Plant (Copyright 2006 Matthias Braun), the custom PlantKing implementation, and this project's portable world controller.

Bundled Plant graphics are existing SuperTux resources, not original CC0 artwork. Their upstream terms and credits are retained; see `ASSET_NOTES.md`, `SUPERTUX-AUTHORS.txt`, and the included license texts. The reused original project crown is CC0-1.0.

## Validation

Checked with the official unmodified SuperTux 0.7.0 Linux AppImage: all ten stages load from the standalone ZIP, resolve their resources, start the controller, and spawn Tux on solid ground. Separate live probes check small-Tux waking, fire/ice interactions, six actual boss landings, hit cooldown, summoned Plants, root darts, emerging roots, and the original victory script opening RoyalGate. Worldmap road reciprocity, reachability, and all ten stops pass static checks. These checks do not constitute a complete manual playthrough.
