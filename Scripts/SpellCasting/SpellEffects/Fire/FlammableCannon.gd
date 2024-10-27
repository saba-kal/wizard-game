class_name FlammableCannon extends Flammable

@export var particle_effect: GPUParticles3D
@export var cannon: Cannon


func light() -> void:
    self.particle_effect.emitting = true
    self.cannon.start_timer()
    await get_tree().create_timer(self.cannon.time_until_fire).timeout
    self.particle_effect.emitting = false
