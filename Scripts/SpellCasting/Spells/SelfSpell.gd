extends Spell

@export var blue_rune_type: BlueRune.BlueRuneType
@export var red_rune_type: RedRune.RedRuneType

signal cast
# Methods below should be overriden by spells that inherit this class.

func cast_spell(blue_rune: BlueRune, red_rune: RedRune, yellow_rune: YellowRune):
    emit_signal("cast")


func supports_runes(blue_rune: BlueRune, red_rune: RedRune, yellow_rune: YellowRune) -> bool:
    return (blue_rune.type == self.blue_rune_type &&
        red_rune.type == self.red_rune_type &&
        yellow_rune.type == YellowRune.YellowRuneType.SELF)


func set_indicator_visible(is_visible: bool):
    pass
