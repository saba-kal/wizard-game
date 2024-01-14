class_name PursueTargetAI extends Node

@export var character_body: CharacterBody3D
@export var nav_agent: NavigationAgent3D
@export var speed: float = 200.0
@export var turn_speed: float = 20.0

var enabled: bool = false
var nav_server_ready: bool = false
var target_position: Vector3


func _ready():
    self.nav_agent.velocity_computed.connect(self.on_nav_agent_velocity_computed)
    call_deferred("actor_setup")


func actor_setup():
    # Wait for the first physics frame so the NavigationServer can sync.
    await get_tree().physics_frame
    self.nav_server_ready = true


func set_enabled(is_enabled: bool) -> void:
    self.enabled = is_enabled


func set_target(new_target: Vector3) -> void:
    self.target_position = new_target


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float):
    if !self.enabled || !self.nav_server_ready:
        return

    self.nav_agent.target_position = self.target_position
    var next_nav_point = self.nav_agent.get_next_path_position()
    if self.nav_agent.is_navigation_finished():
        return

    self.nav_agent.velocity = (next_nav_point - self.global_position).normalized() * self.speed * delta
    self.look_at_target(delta)


func look_at_target(delta: float):
    var look_position = Vector3(self.target_position.x, self.character_body.global_position.y, self.target_position.z)
    if look_position.distance_squared_to(self.character_body.global_position) > 1:
        var original_rotation = self.character_body.quaternion
        self.character_body.look_at_from_position(self.character_body.global_position, look_position, Vector3.UP, true)
        self.character_body.quaternion = original_rotation.slerp(self.character_body.quaternion, delta * self.turn_speed)


func on_nav_agent_velocity_computed(safe_velocity: Vector3):
    if !self.enabled:
        return
    self.character_body.velocity = safe_velocity
    self.character_body.move_and_slide()
