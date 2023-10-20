class_name Spell extends Node3D


# Methods below should be overriden by spells that inherit this class.

func cast_spell(blue_rune: BlueRune, red_rune: RedRune, yellow_rune: YellowRune):
    pass


func supports_runes(blue_rune: BlueRune, red_rune: RedRune, yellow_rune: YellowRune) -> bool:
    return false


func set_indicator_visible(is_visible: bool):
    pass
