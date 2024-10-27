extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func destroy_fort_tower() -> void:
    self.animation_player.play("Fort-Tower_2_001Action_001")
