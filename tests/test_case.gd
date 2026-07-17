class_name TestCase
extends RefCounted

## Base for headless tests. Record failures instead of using assert(),
## which is stripped in release builds and cannot set an exit code.

var failures: PackedStringArray = []


func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func check_eq(actual: Variant, expected: Variant, message: String) -> void:
	check(actual == expected, "%s - got %s, expected %s" % [message, actual, expected])


func check_approx(actual: float, expected: float, message: String) -> void:
	check(
		is_equal_approx(actual, expected),
		"%s - got %s, expected %s" % [message, actual, expected]
	)
