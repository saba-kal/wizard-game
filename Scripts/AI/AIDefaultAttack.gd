class_name AIDefaultAttack extends Node3D

signal attack_started()
signal attack_finished()

@export var attack_delay: float = 2.0
@export var attack_duration: float = 1.0
@export var damage: float = 10.0

var is_attacking: bool = false


func perform_attack() -> void:
    self.attack_started.emit()
    self.is_attacking = true
    var tween = get_tree().create_tween()
    tween.tween_callback(self.attack).set_delay(self.attack_delay)
    tween.tween_callback(self.complete_attack).set_delay(self.attack_duration)


# Should be implemented by inheriting classes
func attack() -> void:
    pass


func complete_attack() -> void:
    self.is_attacking = false
    self.attack_finished.emit()



func is_in_range() -> bool:
    return true
