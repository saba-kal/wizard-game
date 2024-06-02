class_name AreaAttack extends Area3D

signal attack_finished()

@export var area_of_effect: float = 1.0
@export var attack_delay: float = 2.0
@export var attack_duration: float = 1.0
@export var damage: float = 10.0
@export var particle_effect: MultiParticleSystem

var entered_bodies: Array[Node3D] = []
var is_attacking: bool = false


func _ready():
    self.body_entered.connect(self.on_body_entered)
    self.body_exited.connect(self.on_body_exited)


func perform_attack() -> void:
    self.is_attacking = true
    var tween = get_tree().create_tween()
    tween.tween_callback(self.attack).set_delay(self.attack_delay)
    tween.tween_callback(self.complete_attack).set_delay(self.attack_duration)


func attack() -> void:
    for body in self.entered_bodies:
        var health: Health = Util.get_child_node_of_type(body, Health)
        if health != null && self.get_parent() != body:
            health.take_damage(self.damage)
    self.emit_particles()


func emit_particles() -> void:
    if self.particle_effect:
        self.particle_effect.emitting = true


func complete_attack() -> void:
    self.is_attacking = false
    self.attack_finished.emit()


func on_body_entered(body: Node3D) -> void:
    self.entered_bodies.append(body)


func on_body_exited(body: Node3D) -> void:
    self.entered_bodies.erase(body)
