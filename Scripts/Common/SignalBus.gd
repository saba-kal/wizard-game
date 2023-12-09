extends Node


signal rune_slots_changed(blue_rune: BlueRune, red_rune: RedRune, yellow_rune: YellowRune)
signal rune_collected(rune: Rune)
signal spell_cast()
signal player_aim_mode_changed(is_aiming: bool)
signal player_jumped()
signal player_died()
