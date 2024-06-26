extends AIDefaultAttack

signal jumped()

@onready var hitbox: Area3D = $Area3D
@onready var attack_particles: GPUParticles3D = $AttackParticles

func _ready() -> void:
    hitbox.body_entered.connect(_on_body_entered)

func attack() -> void:
    jumped.emit()
    attack_particles.emitting = true

func _on_body_entered(body: Node3D) -> void:
    if not is_attacking: return
    var health: Health = Util.get_child_node_of_type(body, Health)
    if health != null && self.get_parent() != body:
        health.take_damage(self.damage)
    self.is_attacking = false
    
    self.attack_finished.emit()

func complete_attack() -> void:
    pass
