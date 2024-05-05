class_name PhysicsObject extends RigidBody3D

@export var float_force_strength: float = 2.0
@export var on_hit_damage: float = 30.0
@export var minimum_speed_to_damage: float = 20.0

@onready var float_position: Vector3 = self.global_position
@onready var original_gravity_scale: float = self.gravity_scale

var float_enabled: bool = false
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready() -> void:
    self.body_entered.connect(self.on_body_entered)


func set_float_enabled(is_float_enabled: bool) -> void:
    self.float_enabled = is_float_enabled
    if is_float_enabled:
        self.gravity_scale = 0
    else:
        self.gravity_scale = self.original_gravity_scale
    self.apply_force(Vector3.ZERO) # Awakanse the rigid body if in sleep mode


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
    if !self.float_enabled:
        return
    var force: Vector3 = self.float_position - self.global_position
    force = force * self.float_force_strength - self.linear_velocity
    state.apply_force(force)


func on_body_entered(body: Node3D) -> void:
    var health: Health = Util.get_child_node_of_type(body, Health)
    if is_instance_valid(health) && self.linear_velocity.length() >= self.minimum_speed_to_damage:
        health.take_damage(self.on_hit_damage)
