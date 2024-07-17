extends Node


signal rune_slots_changed(blue_rune: BlueRune, red_rune: RedRune, yellow_rune: YellowRune)
signal rune_collected(rune: Rune)
signal spell_cast(targets_self: bool)
signal player_aim_mode_changed(is_aiming: bool)
signal player_jumped()
signal player_died()
signal player_disabled(is_disabled: bool)
signal player_swim_mode_changed(is_swimming: bool)
signal player_mana_regen_changed(is_mana_regen_on: bool)
signal spell_craft_menu_opened()
signal spell_craft_menu_closed()
signal spell_ready_to_cast_updated(is_spell_ready: bool)
