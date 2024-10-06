extends Spell

@export var blue_rune_type: BlueRune.BlueRuneType
@export var red_rune_type: RedRune.RedRuneType
@export var spell_effect_scene: PackedScene
@export var ground_aim_indicator_scene: PackedScene

var ground_aim_indicator: GroundAimIndicator
var max_distance: float = 20.0


func _ready() -> void:
    var player = self.get_tree().get_first_node_in_group("Player")
    self.ground_aim_indicator = self.ground_aim_indicator_scene.instantiate()
    self.ground_aim_indicator.max_distance = self.max_distance
    self.add_child(self.ground_aim_indicator)
    self.ground_aim_indicator.visible = false


func cast_spell(blue_rune: BlueRune, red_rune: RedRune, yellow_rune: YellowRune) -> void:
    var spell_effect: Node3D = self.spell_effect_scene.instantiate()
    self.get_tree().root.add_child(spell_effect)
    spell_effect.global_position = self.get_spell_position(yellow_rune)


func get_spell_position(yellow_rune: YellowRune) -> Vector3:
    if yellow_rune.type == YellowRune.YellowRuneType.GROUND:
        return self.ground_aim_indicator.global_position
    return self.global_position


func supports_runes(blue_rune: BlueRune, red_rune: RedRune, yellow_rune: YellowRune) -> bool:
    return (
        blue_rune.type == self.blue_rune_type &&
        red_rune.type == self.red_rune_type &&
        (yellow_rune.type == YellowRune.YellowRuneType.GROUND || yellow_rune.type == YellowRune.YellowRuneType.SELF)
        )


func set_indicator_visible(is_visible: bool) -> void:
    self.ground_aim_indicator.set_indicator_visible(is_visible)


func can_cast_spell() -> bool:
    return self.ground_aim_indicator.is_valid
