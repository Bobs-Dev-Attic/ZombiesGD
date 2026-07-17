import bpy
import os
import sys

# ---- args after "--" ----
argv = sys.argv[sys.argv.index("--") + 1:]
SRC = argv[0]          # extracted kenney dir
OUT = argv[1]          # output .glb path

MODEL = os.path.join(SRC, "Model", "characterMedium.fbx")
ANIMS = {
    "Idle": os.path.join(SRC, "Animations", "idle.fbx"),
    "Run":  os.path.join(SRC, "Animations", "run.fbx"),
    "Jump": os.path.join(SRC, "Animations", "jump.fbx"),
}


def log(*a):
    print("[convert]", *a)


# ---- clean slate ----
bpy.ops.wm.read_factory_settings(use_empty=True)


def import_fbx(path):
    before = set(bpy.data.objects)
    bpy.ops.import_scene.fbx(filepath=path, automatic_bone_orientation=True)
    return [o for o in bpy.data.objects if o not in before]


def find_armature(objs):
    for o in objs:
        if o.type == "ARMATURE":
            return o
    return None


# ---- base model ----
base_objs = import_fbx(MODEL)
base_arm = find_armature(base_objs)
if base_arm is None:
    log("ERROR: no armature in base model")
    sys.exit(1)
log("base armature:", base_arm.name, "bones:", len(base_arm.data.bones))

# base model may carry its own action (bind pose) - ignore it.

# ---- collect animation actions onto the base armature via NLA ----
if base_arm.animation_data is None:
    base_arm.animation_data_create()

def span(a):
    fr = a.frame_range
    return fr[1] - fr[0]


def pick_real_action(new_actions, keyword):
    # Each anim FBX imports TWO actions: a short "Targeting Pose" stub and the
    # real clip (named like "Root|Root|Run"). Pick the real one: prefer a name
    # containing the clip keyword, otherwise the action with the largest frame
    # span, always excluding obvious pose/bind stubs.
    def is_stub(a):
        n = a.name.lower()
        return "targeting pose" in n or "t-pose" in n or "bind" in n
    real = [a for a in new_actions if not is_stub(a)]
    pool = real if real else list(new_actions)
    kw = keyword.lower()
    named = [a for a in pool if kw in a.name.lower()]
    if named:
        return max(named, key=span)
    return max(pool, key=span) if pool else None


exported = []
for name, path in ANIMS.items():
    if not os.path.exists(path):
        log("skip missing", path)
        continue
    before_actions = set(bpy.data.actions)
    new_objs = import_fbx(path)
    new_actions = [a for a in bpy.data.actions if a not in before_actions]
    action = pick_real_action(new_actions, name)
    # drop the stub/unused actions from this import so they don't get exported
    for a in new_actions:
        if a is not action:
            a.use_fake_user = False
            try:
                bpy.data.actions.remove(a)
            except Exception:
                pass
    if action is None:
        log("no action found for", name)
    else:
        log("selected action for", name, "->", action.name,
            "span", span(action), "keys",
            sum(len(fc.keyframe_points) for fc in action.fcurves))
        action.name = name
        action.use_fake_user = True
        # push to an NLA track on the base armature so the glTF exporter
        # emits one animation per track.
        track = base_arm.animation_data.nla_tracks.new()
        track.name = name
        track.strips.new(name, int(action.frame_range[0]), action)
        exported.append(name)
        log("added animation:", name, "frames", action.frame_range[0], "-", action.frame_range[1])
    # remove the imported extra objects (armature + mesh); the action stays.
    for o in list(new_objs):
        bpy.data.objects.remove(o, do_unlink=True)

log("animations on base:", exported)

# make sure only the base armature + its mesh remain selected for export
bpy.ops.object.select_all(action="SELECT")

# ---- export GLB with all NLA tracks as separate animations ----
bpy.ops.export_scene.gltf(
    filepath=OUT,
    export_format="GLB",
    export_animations=True,
    export_animation_mode="NLA_TRACKS",
    export_apply=False,
    export_yup=True,
)
log("wrote", OUT)

# ---- report what got exported ----
size = os.path.getsize(OUT) if os.path.exists(OUT) else 0
log("RESULT size_bytes", size, "animations", ",".join(exported))
