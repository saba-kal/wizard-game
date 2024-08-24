class_name JumpAttack extends AIDefaultAttack

signal jumped()
signal dived()
signal seek(time: float)

@onready var hitbox: Area3D = $Area3D
@onready var attack_particles: GPUParticles3D = $AttackParticles

var twist_time: float = 0.8
var dive_time:float = 2
var recover_time: float = 2.93
var state: Jump_State = Jump_State.PREPPING

enum Jump_State {
    PREPPING,
    SOARING,
    TWISTING,
    DIVING,
    RECOVERING
}

func _ready() -> void:
    hitbox.body_entered.connect(_on_body_entered)
    attack_particles.emitting = false

func attack() -> void:
    jumped.emit()
    state = Jump_State.SOARING
    var tween = get_tree().create_tween()
    tween.tween_callback(end_soar_time).set_delay(attack_duration)

func end_soar_time() -> void:
    state = Jump_State.TWISTING
    var tween = get_tree().create_tween()
    tween.tween_callback(end_twist).set_delay(dive_time - twist_time)

func end_twist() -> void:
    state = Jump_State.DIVING
    loop_dive()

func loop_dive() -> void:
    if(state != Jump_State.DIVING):
        return
    seek.emit(dive_time)
    var tween = get_tree().create_tween()
    tween.tween_callback(loop_dive).set_delay(recover_time - dive_time)

func end_dive() -> void:
    seek.emit(recover_time)
    state = Jump_State.RECOVERING
    attack_particles.emitting = true
    hitbox.active = true
    var tween = get_tree().create_tween()
    tween.tween_callback(stop_emitting).set_delay(recover_time - dive_time)

func stop_emitting() -> void:
    attack_particles.emitting = false
    hitbox.active = false

func _on_body_entered(body: Node3D) -> void:
    if not is_attacking: return
    var health: Health = Util.get_child_node_of_type(body, Health)
    if health != null && self.get_parent() != body:
        health.take_damage(self.damage)
    self.is_attacking = false

    self.attack_finished.emit()

func complete_attack() -> void:
    pass
