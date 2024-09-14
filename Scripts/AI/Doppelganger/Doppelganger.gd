class_name Doppleganger extends CharacterBody3D

@export var player: CharacterBody3D

func _ready():
    if not player:
        player = self.get_tree().get_first_node_in_group("Player")


func _on_healed(heal_amount):
    var health: Health = Util.get_child_node_of_type(player, Health)
    health.heal(heal_amount)
