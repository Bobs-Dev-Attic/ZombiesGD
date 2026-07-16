extends SceneTree


func _init() -> void:
	var failures := 0
	for path in ["res://tests/test_wave_math.gd"]:
		var test: RefCounted = load(path).new()
		test.run()
	quit(failures)
