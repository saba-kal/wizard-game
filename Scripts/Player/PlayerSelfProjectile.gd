class_name PlayerSelfProjectile extends Node3D

@onready var player: PlayerController = self.get_parent()

var velocity: Vector3
var gravity: float
var is_fired: bool = false


func _process(delta: float) -> void:
    if !self.is_fired:
        return

    self.velocity.y -= self.gravity * delta
    var collision: KinematicCollision3D = self.player.move_and_collide(self.velocity * delta)
    if collision:
        self.is_fired = false
        self.player.set_player_disabled(false)


func fire(direction: Vector3, speed: float, proj_gravity: float) -> void:
    self.velocity = direction * speed
    self.gravity = proj_gravity
    self.is_fired = true
