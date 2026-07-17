# Character assets

Source: Kenney "Animated Characters 3" (CC0 1.0 Universal — see License.txt).

`character.glb` is converted from the pack's FBX files by `tools/convert_character_fbx.py`
(run with Blender 4.x `--background`), which merges the separate idle/run/jump animation
FBXs onto the shared skeleton and exports one GLB. It carries a 58-bone Skeleton3D, a single
skinned mesh (`characterMedium`, ~3.76 units tall in T-pose, faces -Z, feet at origin), and an
AnimationPlayer with clips **Idle / Run / Jump**. It is untextured — apply a skin from
`skins/` as the mesh albedo (humanMaleA for the player, zombieMaleA for zombies).

To regenerate: extract the pack somewhere, then
`"<blender>" --background --python tools/convert_character_fbx.py -- <extracted_dir> assets/characters/character.glb`
