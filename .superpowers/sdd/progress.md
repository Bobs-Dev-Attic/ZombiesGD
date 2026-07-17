# SDD Progress Ledger

Branch: claude/godot-connection-check-a249a5 (NOT feat/zombie-survival-shooter — that
branch is checked out in the main worktree at C:\Users\Bob\Projects\ZombieGD and cannot
be checked out here simultaneously. Both started from 9141147.)
Plan: docs/superpowers/plans/2026-07-16-zombie-survival-shooter.md
Started: 2026-07-16

Scope this session: Tasks 2-5 (Upgrades, Arena, InputManager, Player) — goal is a
player you can move around in an arena.

Pre-work: commit 4db723d — fixed the plan's test runner, which declared `failures` but
never incremented it, so `quit(failures)` always exited 0 (verified: a failing assert
printed SCRIPT ERROR and still exited 0). Replaced assert() with a recording `TestCase`
base (check/check_eq/check_approx); runner now exits 1 on failure. User approved this
deviation. The plan's Task 1/2 assert() sample code is therefore STALE.
Also added .gitignore for .godot/ and the machine-local .mcp.json.

Task 1: complete (pre-existing, commit 9141147)
Task 2: complete (commits 4db723d..12888f9, review clean — spec ✅, quality approved)
Task 3: complete (commit 4e967ef, review clean — spec ✅, quality approved)
Task 4: complete (commits 328b64a..7b5b089, review clean after fix — spec ✅, quality approved)
Task 5: complete (commit da99885, review clean — spec ✅, quality approved)

## Minor findings deferred to final whole-branch review

- Task 2: `move_speed()` and `max_hp()` are only tested at level-0 base values; a
  coefficient bug (0.75 -> 0.5, or 25.0 -> 10.0) would not be caught. `damage()` and
  `fire_cooldown()` are pinned at non-zero levels. Gap mirrors the plan's own sample test.
- Task 3: `scenes/main.tscn` header declares `load_steps=15` but only 13 resources are
  declared (should be 14). Cosmetic — Godot treats it as a progress hint, load is clean.
- Task 4: `set_touch_move`'s 0.05 deadzone threshold is pure logic that could have been
  extracted+tested like `normalize_move_vector` was; line drawn slightly inconsistently.
- Task 5: `player.gd`'s `var hp: float = 100.0` duplicates Upgrades.max_hp()'s base as a
  magic number; overwritten in _ready(), no functional risk.
- Task 5: `PlayerHealth extends RefCounted` but is never instantiated (static funcs only).

## Deviations from plan (both deliberate, one user-approved, one controller judgment)

1. Test runner / TestCase (commit 4db723d) — USER APPROVED. See pre-work above.
2. InputManager touch latch (commit 7b5b089) — CONTROLLER JUDGMENT, user did not answer
   when asked. Plan's sample set `touch_enabled = DisplayServer.is_touchscreen_available()`
   in `_ready()` with no way back to false. User's machine HAS a touchscreen (verified via
   Get-PnpDevice), so WASD would have been silently dead: get_move_vector() would read
   touch_move, which stays (0,0) until Task 9's joystick exists. Fix: default false; only
   set_touch_move/set_touch_fire enable it (which Task 9's joystick will call).
   REVISIT IN TASK 9 — confirm real mobile still enables touch mode.
3. Task 5 spawn Y (0,1,0) -> (0,1.4,0) — forced by real geometry: ground top y=0.5 +
   capsule half-height 0.9. Plan's value would have sunk the player into the floor.
4. Task 5 aim math generalized from the plan's `t := -from.y / dir.y` (assumes ground at
   y=0) to plane-at-player-height; plan's formula would have introduced a ~1.4m aim offset.
