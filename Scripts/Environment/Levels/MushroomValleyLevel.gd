extends Node3D

@export var particle_effect: GPUParticles3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_mushroom_valley_tower_destroyed: bool = false

func _ready() -> void:
    SignalBus.mushroom_valley_tower_hit.connect(self.destroy_fort_tower)
    self.animation_player.speed_scale = 0.2
    self.particle_effect.emitting = false


func destroy_fort_tower() -> void:

    if self.is_mushroom_valley_tower_destroyed:
        # Tower is already destroyed
        return

    self.is_mushroom_valley_tower_destroyed = true

    self.particle_effect.emitting = true
    await get_tree().create_timer(2.0).timeout

    SignalBus.mushroom_valley_tower_destruction_started.emit()
    self.animation_player.play("Fort-Tower_2_001Action_001")

    self.particle_effect.emitting = false
