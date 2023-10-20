extends Spell

@export var fire_column_scene: PackedScene
@export var ice_column_scene: PackedScene

@onready var ground_aim_indicator: Node3D = $GroundAimIndicator


func _ready():
    var player = self.get_tree().get_first_node_in_group("Player")
    self.ground_aim_indicator.visible = false


func cast_spell(blue_rune: BlueRune, red_rune: RedRune, yellow_rune: YellowRune):
    var spell_effect: Node3D = self.instantiate_spell_effect(blue_rune)
    self.get_tree().root.add_child(spell_effect)
    spell_effect.global_position = self.get_spell_position(yellow_rune)


func instantiate_spell_effect(blue_rune: BlueRune) -> Node3D:
    if blue_rune.type == BlueRune.BlueRuneType.FIRE:
        return self.fire_column_scene.instantiate()
    return self.ice_column_scene.instantiate()


func get_spell_position(yellow_rune: YellowRune) -> Vector3:
    if yellow_rune.type == YellowRune.YellowRuneType.GROUND:
        return self.ground_aim_indicator.global_position
    return self.global_position


func supports_runes(blue_rune: BlueRune, red_rune: RedRune, yellow_rune: YellowRune) -> bool:
    return ((
            blue_rune.type == BlueRune.BlueRuneType.FIRE ||
            blue_rune.type == BlueRune.BlueRuneType.ICE
        ) &&
        red_rune.type == RedRune.RedRuneType.DETRIMENT &&
        (
            yellow_rune.type == YellowRune.YellowRuneType.GROUND ||
            yellow_rune.type == YellowRune.YellowRuneType.SELF
        ))


func set_indicator_visible(is_visible: bool):
    self.ground_aim_indicator.visible = is_visible
