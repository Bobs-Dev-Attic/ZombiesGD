extends TestCase

const ShopHelpers := preload("res://scripts/ui/shop_helpers.gd")


func run() -> void:
	var u := Upgrades.new()

	# --- below TIER_MAX, affordable ---
	var state := ShopHelpers.tier_button_state(WeaponStats.Role.RANGED, u, 200)
	check_eq(state["label"], "Upgrade to Shotgun  (120)", "tier label at TIER_MIN, affordable")
	check_eq(state["disabled"], false, "tier button enabled when affordable and below TIER_MAX")

	# --- below TIER_MAX, unaffordable ---
	state = ShopHelpers.tier_button_state(WeaponStats.Role.MELEE, u, 50)
	check_eq(state["label"], "Upgrade to Axe  (120)", "tier label at TIER_MIN, unaffordable")
	check_eq(state["disabled"], true, "tier button disabled when cost exceeds points")

	# --- at TIER_MAX ---
	u.try_buy_tier(WeaponStats.Role.THROWN, 1000)
	state = ShopHelpers.tier_button_state(WeaponStats.Role.THROWN, u, 1000)
	check_eq(state["label"], "Cluster Grenade (max)", "tier label at TIER_MAX shows current name")
	check_eq(state["disabled"], true, "tier button disabled at TIER_MAX regardless of points")
