class_name ShopHelpers
extends RefCounted

## Pure display-logic helpers for the shop UI, split out of scripts/ui/shop.gd
## specifically so they stay preloadable/unit-testable under the `-s`
## headless test runner: shop.gd itself uses GameManager.State as a type
## hint (an autoload reference resolved only when the project runs
## normally), so shop.gd cannot be preloaded under `-s` — see
## tests/test_shop_helpers.gd. This file references only autoload-free
## RefCounted classes (WeaponStats, Upgrades).

const WeaponStats := preload("res://scripts/weapon_stats.gd")
const Upgrades := preload("res://scripts/upgrades.gd")


## Maps a role's current tier state to a buy-button label + disabled bool:
## - at TIER_MAX: "<current name> (max)", disabled.
## - otherwise: "Upgrade to <next name>  (<cost>)", disabled iff unaffordable.
static func tier_button_state(role: WeaponStats.Role, upgrades: Upgrades, points: int) -> Dictionary:
	var tier: int = upgrades.tiers[role]
	if tier >= WeaponStats.TIER_MAX:
		return {
			"label": "%s (max)" % WeaponStats.weapon_name(role, tier),
			"disabled": true,
		}
	var next_name := WeaponStats.weapon_name(role, tier + 1)
	var cost := upgrades.tier_cost(role)
	return {
		"label": "Upgrade to %s  (%d)" % [next_name, cost],
		"disabled": cost > points,
	}
