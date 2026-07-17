extends Node

## Version (autoload): the single source of truth for the build version.
##
## Bump VERSION here and add a matching CHANGELOG.md entry with every change.
## The on-screen label reads this at runtime, so the displayed version can
## never drift from the code — there is no second copy of the number.
##
## Semantic-ish versioning while pre-1.0: MINOR for a new gameplay system
## (a weapon role, the wave loop), PATCH for fixes and small additions.

const VERSION: String = "0.7.0"


## e.g. "v0.4.0" — what the HUD shows.
func display_string() -> String:
	return "v%s" % VERSION
