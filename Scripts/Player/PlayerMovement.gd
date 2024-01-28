class_name PlayerMovement extends Node3D

@export var player_node: CharacterBody3D
@export var player_visuals_node: Node3D
@export var speed: float = 5
@export var aim_speed: float = 3
@export var jump_velocity: float = 6
@export var turn_speed: float = 20
@export var animation_tree: AnimationTree

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var gravity_adjustment: float = 0
var input_direction: Vector2
var disabled: bool = false
var third_persion_camera: ThirdPersonCamera
var player_swimming: PlayerSwimming


func _ready():
    self.animation_tree.active = true
    self.third_persion_camera = Util.get_child_node_of_type(self.get_parent(), ThirdPersonCamera)
    self.player_swimming = Util.get_child_node_of_type(self.get_parent(), PlayerSwimming)
    SignalBus.player_died.connect(self.on_player_died)


func _physics_process(delta):

    if self.disabled:
        self.input_direction = Vector2.ZERO
        return
    self.process_velocity(delta)
    self.process_rotation(delta)


func process_velocity(delta):
    if !self.player_node.is_on_floor() && !self.player_swimming.is_swimming:
        self.player_node.velocity.y -= (self.gravity + self.gravity_adjustment) * delta

    if Input.is_action_just_pressed("jump") && self.player_node.is_on_floor():
        self.apply_vertical_velocity(self.jump_velocity)
        SignalBus.player_jumped.emit()

    self.input_direction = Input.get_vector(
        "move_left", "move_right", "move_forward", "move_backward")
    var direction = (self.player_node.transform.basis *
        Vector3(self.input_direction.x, 0, self.input_direction.y)).normalized()

    var move_speed: float = self.speed
    if self.third_persion_camera.is_aiming:
        move_speed = self.aim_speed

    if direction:
        self.player_node.velocity.x = direction.x * move_speed
        self.player_node.velocity.z = direction.z * move_speed
    else:
        self.player_node.velocity.x = move_toward(self.player_node.velocity.x, 0, move_speed)
        self.player_node.velocity.z = move_toward(self.player_node.velocity.z, 0, move_speed)

    self.player_node.move_and_slide()


func apply_vertical_velocity(vertical_velocity: float):
    self.player_node.velocity.y += vertical_velocity


func set_vertical_velocity(vertical_velocity: float):
    self.player_node.velocity.y = vertical_velocity


func process_rotation(delta):
    var target_quaternion: Quaternion
    if self.third_persion_camera.is_aiming:
        target_quaternion = Quaternion.from_euler(Vector3(0, 0, 0))
    else:
        var target_y_rotation = Vector3.FORWARD.signed_angle_to(Vector3(self.input_direction.x, 0, self.input_direction.y), Vector3.UP)
        target_quaternion = Quaternion.from_euler(Vector3(0, target_y_rotation, 0))
    
    self.player_visuals_node.quaternion = self.player_visuals_node.quaternion.slerp(target_quaternion, delta * self.turn_speed)

    if self.input_direction || self.third_persion_camera.is_aiming:
        var player_rotation = Quaternion.from_euler(Vector3(0, self.third_persion_camera.get_camera_y_rotation(), 0))
        self.player_node.quaternion = self.player_node.quaternion.slerp(player_rotation, delta * self.turn_speed)


func is_running() -> bool:
    return !self.third_persion_camera.is_aiming && self.player_node.velocity.length_squared() > 0.1


func is_walking() -> bool:
    return self.third_persion_camera.is_aiming && self.player_node.velocity.length_squared() > 0.1


func is_on_floor() -> bool:
    return self.player_node.is_on_floor()


func on_player_died() -> void:
    self.disabled = true


func get_velocity() -> Vector3:
    return self.player_node.velocity
