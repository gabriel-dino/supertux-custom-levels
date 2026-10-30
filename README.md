# SuperTux custom worlds

Five standalone add-ons for **regular SuperTux 0.7.0**, containing 45 levels, worldmaps, animated custom creatures, collectibles, bounce objects, gates, and bosses.

**No custom game, engine source, compilation, or extra asset download is required.** Install the official [SuperTux 0.7.0 release](https://www.supertux.org/download), then install a world ZIP. SuperTux 0.6.3 is not supported. Newer versions may work but have not been verified.

| World | Levels | Download file |
| --- | ---: | --- |
| [IceSlime Trail](ice_slime_trail/README.md) | 5 | [ice_slime_trail.zip](https://github.com/gabriel-dino/supertux-custom-levels/releases/download/1.1/ice_slime_trail.zip) |
| [Frostbound Frontier](frostbound_frontier/README.md) | 10 | [frostbound_frontier.zip](https://github.com/gabriel-dino/supertux-custom-levels/releases/download/1.1/frostbound_frontier.zip) |
| [Harvest of Shadows](harvest_of_shadows/README.md) | 10 | [harvest_of_shadows.zip](https://github.com/gabriel-dino/supertux-custom-levels/releases/download/1.1/harvest_of_shadows.zip) |
| [Easter Eggspedition](easter_eggspedition/README.md) | 10 | [easter_eggspedition.zip](https://github.com/gabriel-dino/supertux-custom-levels/releases/download/1.1/easter_eggspedition.zip) |
| [The Lost Plant World](lost_plant_world/README.md) | 10 | [lost_plant_world.zip](https://github.com/gabriel-dino/supertux-custom-levels/releases/download/1.1/lost_plant_world.zip) |

[Release 1.1](https://github.com/gabriel-dino/supertux-custom-levels/releases/tag/1.1) provides installable ZIPs for all five worlds, including The Lost Plant World. Each ZIP includes its required custom assets, gameplay scripts where applicable, and license texts. Download each world separately using the links above.

## Install and play

1. Download a world ZIP from this repository's **Releases** attachments. Keep it zipped. GitHub's automatic “Download ZIP” contains the source repository and is not an installable add-on.
2. Start **SuperTux 0.7.0**, open **Add-ons → Install from file**, and drag the downloaded ZIP from your file manager onto the game window.
3. Return to the main menu, open **Contrib Levels → User Contrib Levels**, and choose the world. Ensure the add-on is enabled if it does not appear.

The desktop “Install from file” screen uses drag and drop. As a manual alternative, put the ZIP in the `addons/` directory under your SuperTux user directory, restart, and enable it in Add-ons. Do not unpack the archive or copy its internal folders into the game installation.

The world map saves progress when entered from Contrib Levels. These add-ons are distributed here; they will not appear in the official online add-on catalog unless separately submitted and accepted.

## Custom features on the regular engine

- IceSlimes use the native snowball object with their original animated artwork.
- Other custom creatures use standard ScriptedObjects controlled by bundled Squirrel code: ground patrols, ledge turns, hops, bounded flights, bat dives, two-stomp armor, and reviving Bone Walkers.
- Painted eggs and candy use native coins. Transparent companion coins preserve their original values (five and three), including native coin totals. Key eggs still open the gates.
- Flowers and cauldrons use stationary native trampolines with their custom artwork. Holding Jump gives a higher bounce.
- The Marshmallow Monarch retains five hits, windup/hop/dizzy phases, a faster final phase, crown health icons, and victory gates. Stars and projectiles cannot skip the boss.
- The Lost Plant World adds sleeping Plants and a six-hit Plant King with three attack phases, summons, root darts, and emerging roots. The portable boss uses normal-size Plant artwork and a separate crown. See its [README](lost_plant_world/README.md) for adaptation differences and validation details.
- Checkpoints, Tux Dolls, switches, exits, and map progression use native game features.

This is a portable adaptation of the earlier C++ prototype, not a binary-identical simulation. Native trampoline launch speeds replace the prototype's custom values. Armor damage/freeze feedback uses flashing instead of C++ sprite tinting. Fire/ice interactions with scripted enemies are approximated by the controller alongside native projectiles; projectile collisions with other native enemies may differ. The custom controller currently targets the first player; single-player is the supported mode.

## License

Original levels, text, and generated artwork use **CC0-1.0**. Portable scripts and SuperTux-derived worldmap tileset definitions use **GPL-3.0-or-later**. Bundled legacy Plant graphics and referenced game resources keep their upstream licenses. See [LICENSE.md](LICENSE.md) for the exact scope; each downloadable pack includes its applicable license texts.
