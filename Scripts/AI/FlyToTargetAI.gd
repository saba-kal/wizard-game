class_name FlyToTargetAI extends Node

@export var speed: float = 7.0
@export var acceleration: float = 100.0
@export var turn_speed: float = 5.0
@export var stop_distance: float = 5.0
@export var circle_flight_radius: float = 5.0
@export var min_flight_height: float = 5.0

@onready var character_body: CharacterBody3D = self.get_parent()
@onready var circular_flight_helper: Node3D = $CircularFlightHelper
@onready var circular_flight_target: Node3D = $CircularFlightHelper/CircularFlightTarget

var is_active: bool = false
var target_position: Vector3
var is_circle_flight_active: bool = false
var previous_velocity: Vector3


func _ready():
    self.min_flight_height = self.min_flight_height + self.character_body.global_position.y
    self.circular_flight_target.position = Vector3(0, 0, -self.circle_flight_radius)


func _physics_process(delta: float) -> void:
    if !self.is_active:
        return

    self.previous_velocity = self.character_body.velocity
    if self.is_circle_flight_active:
        self.circle_target(delta)
    else:
        self.fly_to_target(delta)
    self.face_velocity(delta)


func fly_to_target(delta: float) -> void:

    var adjusted_target_pos: Vector3 = self.target_position
    if self.character_body.global_position.y < self.min_flight_height:
        adjusted_target_pos.y += 30.0

    var target_velocity = Vector3.ZERO
    if !self.target_reached():
        var direction: Vector3 = self.character_body.global_position.direction_to(adjusted_target_pos)
        target_velocity = direction * self.speed

    self.character_body.velocity = self.character_body.velocity.move_toward(target_velocity, delta * self.acceleration)
    self.character_body.move_and_slide()


func circle_target(delta: float) -> void:

    var angular_speed = self.speed / self.circle_flight_radius
    self.circular_flight_helper.global_position = self.target_position
    self.circular_flight_helper.rotate_y(delta * angular_speed)

    var direction: Vector3 = self.character_body.global_position.direction_to(self.circular_flight_target.global_position)
    var target_velocity: Vector3 = direction * self.speed
    self.character_body.velocity = self.character_body.velocity.move_toward(target_velocity, delta * self.acceleration)
    self.character_body.move_and_slide()


func face_velocity(delta: float) -> void:

    if self.character_body.velocity.length_squared() < 0.1:
        return

    # Look direction
    var original_rotation: Quaternion = self.character_body.quaternion
    self.character_body.look_at(self.character_body.global_position + self.character_body.velocity)
    self.character_body.quaternion = original_rotation.slerp(self.character_body.quaternion, delta * self.turn_speed)

    # Roll towards velocity change
    var previous_velocity_2d = Vector2(self.previous_velocity.x, self.previous_velocity.z)
    var current_velocity_2d = Vector2(self.character_body.velocity.x, self.character_body.velocity.z)
    var roll_angle_change: float = clampf(-current_velocity_2d.angle_to(previous_velocity_2d), -0.025, 0.025)
    self.character_body.rotate_object_local(Vector3.FORWARD, roll_angle_change)


func set_enabled(is_enabled: bool) -> void:
    self.is_active = is_enabled


func set_target(new_target: Vector3) -> void:
    self.target_position = new_target


func set_circular_flight_enabled(is_enabled: bool) -> void:
    if !self.is_circle_flight_active && is_enabled:
        # first time activating circular flight.
        self.circular_flight_helper.global_position = self.target_position
        self.circular_flight_helper.look_at(Vector3(self.target_position.x, self.circular_flight_helper.global_position.y, self.target_position.z))
    self.is_circle_flight_active = is_enabled


func target_reached() -> bool:
    return self.character_body.global_position.distance_squared_to(self.target_position) < self.stop_distance * self.stop_distance
