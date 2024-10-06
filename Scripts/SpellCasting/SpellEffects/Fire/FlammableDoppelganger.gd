extends "res://Scripts/SpellCasting/SpellEffects/Fire/FlammableCharacter.gd"

var flammable_player: Flammable

func _ready():
    super()
    var player: CharacterBody3D = get_parent().player
    flammable_player = Util.get_child_node_of_type(player, Flammable)

func light():
    super()
    flammable_player.light()


func extinguish():
    super()
    flammable_player.extinguish()


func un_light():
    super()
    flammable_player.un_light()


func un_extinguish():
    super()
    flammable_player.un_extinguish()
