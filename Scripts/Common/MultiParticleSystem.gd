@tool
class_name MultiParticleSystem extends Node3D

@export var emitting: bool:
    get:
        return self.is_emitting
    set(value):
        self.set_emitting(value)
@export var particle_systems: Array[GPUParticles3D]

var is_emitting: bool = false


func _ready():
    self.connect_particel_signals()


func set_emitting(value: bool) -> void:
    self.is_emitting = value
    for particle_system: GPUParticles3D in self.particle_systems:
        particle_system.emitting = self.is_emitting
    if Engine.is_editor_hint():
        self.connect_particel_signals()


func connect_particel_signals() -> void:
    for particle_system: GPUParticles3D in self.particle_systems:
        if !particle_system.finished.is_connected(self.on_particle_finished):
            particle_system.finished.connect(self.on_particle_finished)


func on_particle_finished() -> void:
    for particle_system: GPUParticles3D in self.particle_systems:
        if particle_system.emitting:
            return
    self.set_emitting(false)
