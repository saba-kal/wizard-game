class_name Health extends Node3D

signal damage_taken(damage: float)
signal healed(heal_amount: float)
signal health_lost()

@export var max_health: float = 100

var current_health: float = -1


func _enter_tree():
    self.current_health = self.max_health


func take_damage(damage: float):
    self.current_health -= damage
    self.current_health = max(self.current_health, 0)
    self.damage_taken.emit(damage)
    if current_health <= 0:
        self.health_lost.emit()


func heal(heal_amount: float):
    self.current_health += heal_amount
    self.current_health = clamp(self.current_health, 0, self.max_health)
    self.healed.emit(heal_amount)
