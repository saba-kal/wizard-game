class_name AreaAttack extends Area3D

signal attack_finished()
signal attack_started()

@export var attack_delay: float = 2.0
@export var attack_duration: float = 1.0
@export var damage: float = 10.0
@export var particle_effect: Node3D

var entered_bodies: Array[Node3D] = []
var is_attacking: bool = false


func _ready() -> void:
    self.body_entered.connect(self.on_body_entered)
    self.body_exited.connect(self.on_body_exited)


func perform_attack() -> void:
    self.is_attacking = true
    self.attack_started.emit()
    var tween = get_tree().create_tween()
    tween.tween_callback(self.attack).set_delay(self.attack_delay)
    tween.tween_callback(self.complete_attack).set_delay(self.attack_duration)


func attack() -> void:
    for body in self.entered_bodies:
        var health: Health = Util.get_child_node_of_type(body, Health)
        if health != null && self.get_parent() != body:
            health.take_damage(self.damage)
    self.set_particles_enabled(false)


func complete_attack() -> void:
    self.is_attacking = false
    self.attack_finished.emit()
    self.set_particles_enabled(false)


func set_particles_enabled(enabled: bool) -> void:
    if self.particle_effect:
        if self.particle_effect is MultiParticleSystem:
            self.particle_effect.emitting = enabled
        elif self.particle_effect is GPUParticles3D:
            self.particle_effect.emitting = enabled


func on_body_entered(body: Node3D) -> void:
    self.entered_bodies.append(body)


func on_body_exited(body: Node3D) -> void:
    self.entered_bodies.erase(body)
