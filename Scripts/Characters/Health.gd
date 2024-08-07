class_name Health extends Node3D

signal damage_taken(damage: float)
signal healed(heal_amount: float)
signal health_lost()

@export var max_health: float = 100
@export var is_player: bool = false

var current_health: float = -1
var is_immune: bool = false


func _enter_tree():
    self.current_health = self.max_health


func take_damage(damage: float):
    if self.is_immune:
        return
    self.current_health -= damage
    self.current_health = max(self.current_health, 0)
    self.damage_taken.emit(damage)
    if current_health <= 0:
        self.health_lost.emit()
        if self.is_player:
            SignalBus.player_died.emit()


func heal(heal_amount: float):
    self.current_health += heal_amount
    self.current_health = clamp(self.current_health, 0, self.max_health)
    self.healed.emit(heal_amount)
