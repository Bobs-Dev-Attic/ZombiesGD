extends Label

## Shows the build version in the corner of the screen. Reads the Version
## autoload at runtime rather than hardcoding a string, so bumping
## Version.VERSION is the only step needed to update what the player sees.


func _ready() -> void:
	text = Version.display_string()
