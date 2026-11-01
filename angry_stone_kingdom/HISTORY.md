# Cercetare istorică Angry Stone

Directorul `.git` al arborelui primit este gol. `git log` nu poate citi istoricul
upstream. Metadatele au fost recuperate de la API-ul public al proiectului:

- [Istoricul codului](https://api.github.com/repos/SuperTux/supertux/commits?path=src/badguy/angrystone.cpp&per_page=100)
- [Istoricul resurselor](https://api.github.com/repos/SuperTux/supertux/commits?path=data/images/creatures/angrystone&per_page=100)

Răspunsurile complete sunt păstrate în `tools/angry_stone_kingdom/history/`.
Nu am găsit o eliminare a clasei în acest istoric; implementarea era încă prezentă
în arhiva locală. „Restaurare” înseamnă aici reactivarea în editor și repararea
comportamentului rămas incomplet după schimbarea API-ului de coliziune.

## Repere verificabile

1. [01549e7cabf36e3e0d0a53fd5d318d7a69cbf1b5](https://github.com/SuperTux/supertux/commit/01549e7cabf36e3e0d0a53fd5d318d7a69cbf1b5),
   3 martie 2006: „adding Christoph's badguy code for Grumbel's AngryStone”.
   Sursa arhivată ca `angrystone-2006.cpp.txt` verifică viteza de 240 px/s,
   timpii 0,5 / 1 / 0,5 s, alinierea pe axe și oprirea la perete cu memorarea
   direcției. Codul inițial folosea normale de coliziune, eliminate ulterior
   din API. Antetul său istoric GPL-2.0-or-later este păstrat în copia arhivată;
   fișierul activ păstrează antetul GPL-3.0-or-later primit cu proiectul.
2. [e8f7edf76b317dd795fca90d64ef821eba07c142](https://github.com/SuperTux/supertux/commit/e8f7edf76b317dd795fca90d64ef821eba07c142),
   3 martie 2006: „angrystone is now invulnerable”. Nu l-am transformat într-un
   inamic care poate fi strivit prin săritură obișnuită.
3. [2892ebda09d24c977547159e34abf0244884b89e](https://github.com/SuperTux/supertux/commit/2892ebda09d24c977547159e34abf0244884b89e),
   9 iulie 2006: integrarea noului sistem de coliziune. În sursa locală,
   tratarea vechilor normale era închisă într-un bloc `#if 0` și marcată TODO.
4. [d68b624b813f1bf387cbb121ae054fb57893a236](https://github.com/SuperTux/supertux/commit/d68b624b813f1bf387cbb121ae054fb57893a236),
   27 iulie 2015: „Angrystone is now freezable when not attacking”. Copia
   `angrystone-2015.cpp.txt` verifică `state != ATTACKING`. Această condiție a
   fost readusă; viteza este oprită imediat la înghețare.

La impact am ales recuperarea de 0,5 s înaintea revenirii la IDLE; versiunea din
2006 revenea imediat la IDLE. Este o adaptare explicită pentru a evita rearmarea
imediată la contact cu platforme mobile; restul detecției și ciclului rămân cele
verificate. Nu există un comportament istoric de patrulare/rostogolire continuă.
Rostogolirea este exclusiv o mecanică nouă a boss-ului.

## Sprite-uri și sunete

Cele trei PNG-uri locale sunt identice octet cu octet cu versiunile din
[56cd6ed40f52da5f5fdf949f0c10208ee896d98f](https://github.com/SuperTux/supertux/tree/56cd6ed40f52da5f5fdf949f0c10208ee896d98f/data/images/creatures/angrystone)
(2016). Hash-uri SHA-256, verificate după descărcarea copiilor istorice:

| Fișier | SHA-256 |
|---|---|
| `idle-0.png` | `1894fc846fb944dd3793735a8f00d79bb9423445fe4ea5b42c4c603acf5d92b8` |
| `charging-0.png` | `1452b747602df1d90b5aadd17a0e1739f83324e3ee14f509bf2c16931360545a` |
| `attacking-0.png` | `6a651cf87fb2e83a6725ed8196d44458f85e00113d064705256bf6518158a183` |

Nu am găsit sunete dedicate în implementările Angry Stone inspectate. Nu pretind
recuperarea unui sunet original necunoscut. Boss-ul reutilizează `thud.ogg`,
`icecrash.ogg` și sunetele pietrelor lui Mole. Desenarea mărită a sprite-ului,
coroana, ochii, rotația și animația de înfrângere sunt cod nou; niciun PNG original
Angry Stone nu a fost modificat.
