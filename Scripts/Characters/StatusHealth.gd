class_name StatusHealth extends Node3D

@export var max_health: float = 100
@export var cool_down: float = 5
@export var recharge_rate: float = 10


@onready var health: Health = $Health

var time_since_damage_taken: float = 10
var current_health: float = -1


func _enter_tree():
    $Health.max_health = max_health
    self.current_health = self.max_health


func _process(delta: float):
    if self.time_since_damage_taken > self.cool_down:
        self.health.heal(self.recharge_rate * delta)
    self.time_since_damage_taken += delta


func take_damage(damage: float):
    self.health.take_damage(damage)
    self.time_since_damage_taken = 0


func get_current_health() -> float:
    return self.health.current_health
