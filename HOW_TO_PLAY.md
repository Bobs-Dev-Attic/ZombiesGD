# How to Play ZombieGD

A top-down wave-survival shooter. Hold out against escalating waves of zombies,
spend the points you earn between waves, and see how far you get.

## Running the game

You need Godot 4.7.x (standard build). Then either:

- **From the Godot editor:** open the project folder and press **F5**.
- **From a terminal:**
  ```
  godot --path C:\Users\Bob\Projects\ZombieGD
  ```

The build version shows in the bottom-right corner of the screen.

## Goal

Survive. Each wave sends more zombies, and they get tougher and faster as the
wave number climbs. Killing a zombie earns points. Clear the wave and you get a
shop; die and you can retry from wave 1.

## Controls

| Action | Desktop |
|--------|---------|
| Move | **W A S D** |
| Aim | **Mouse** |
| Fire (ranged) | **Left mouse button** (hold) |
| Throw grenade | **G** |
| Melee | **Automatic** — swings on its own when a zombie is close and in front of you |

Mobile/touch controls are planned but not in yet.

## Your three weapons

You carry all three at once — there is no switching. Each works on its own
cooldown, so you can fire, swing, and throw independently.

- **Ranged** (main gun) — hitscan, fired with the mouse. Reliable single-target damage.
- **Melee** — swings automatically when a zombie is within reach and inside the
  arc in front of your aim. Your close-range answer; face the thing you want to hit.
- **Thrown** (grenade) — lobbed on **G** with a long cooldown. Area damage that
  falls off toward the edge of the blast. Good against clusters.

## The shop (between waves)

Clear a wave and the shop opens. You cannot fire while it is open, but you can
still move. Spend points, then press **Next Wave** when you are ready.

What you can buy:

- **Player:** Move Speed, Max HP.
- **Per weapon role (Ranged / Melee / Thrown):**
  - **Damage** — more damage per hit.
  - **Fire Rate** — shorter cooldown.
  - **Tier upgrade** — a one-time jump to the stronger weapon in that role:
    - Ranged: Pistol → **Shotgun** (fires a 5-pellet spread)
    - Melee: Knife → **Axe** (longer reach, much wider swing arc — hits crowds)
    - Thrown: Grenade → **Cluster Grenade** (a main blast plus four bomblets)

Stat upgrades get a little more expensive each time you buy them; tier upgrades
are a flat one-time cost. Tier upgrades change *how* the weapon behaves, not just
its numbers — the shotgun and axe trade single-target punch for coverage, so
pick based on how you like to fight.

## Dying

When your HP hits zero it is game over. Hit **Retry** to start a fresh run from
wave 1 with a clean slate.

## Tips

- Keep moving. Standing still lets zombies surround you, and melee only covers
  the arc in front of you.
- Grenades are on a long cooldown — save them for when zombies bunch up.
- Early points are precious: a couple of ranged-damage buys early make the first
  several waves much easier, but banking toward a tier upgrade changes your whole
  playstyle.
