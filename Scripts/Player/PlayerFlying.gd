class_name PlayerFlying extends Node

@export var speed: float = 50

@onready var player_body: CharacterBody3D = self.get_parent()

var third_person_camera: ThirdPersonCamera
var player_movement: PlayerMovement
var is_enabled: bool = false
var direction: Vector3 = Vector3.ZERO
var original_gravity: Vector3


func _ready() -> void:
    self.original_gravity = self.player_body.get_gravity()
    self.third_person_camera = Util.get_child_node_of_type(self.player_body, ThirdPersonCamera)
    self.player_movement = Util.get_child_node_of_type(self.player_body, PlayerMovement)


func _physics_process(delta: float) -> void:
    if !self.is_enabled:
        return
    var camera_y_rotation: float = self.third_person_camera.get_camera_y_rotation()
    var actual_direction = self.direction.rotated(Vector3.UP, camera_y_rotation).normalized()
    self.player_body.move_and_collide(actual_direction * self.speed * delta)
    if self.direction != Vector3.ZERO:
        self.player_movement.player_visuals_node.global_rotation = Vector3(0, camera_y_rotation , 0)


func set_flight_direction(dir: Vector3) -> void:
    self.direction = dir.normalized()


func set_enabled(enabled: bool) -> void:
    self.is_enabled = enabled;
