class_name ThirdPersonCamera extends Node3D

@export var camera_target: Node3D
@export var horizontal_pivot: Node3D
@export var vertical_pivot: Node3D
@export var spring_arm: SpringArm3D
@export var camera: Camera3D
@export var horizontal_sensitivity: float = 0.1
@export var vertical_sensitivity: float = 0.1
@export var aim_fov: float = 50
@export var aim_x_offset: float = 3
@export var aim_transition_duration: float = 0.1

var initial_camera_fov: float = 60
var is_aiming: bool = false
var aim_mode_enabled: bool = false
var aim_mode_forever_disabled: bool = false


func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    self.initial_camera_fov = self.camera.fov
    self.spring_arm.add_excluded_object(self.camera_target)
    SignalBus.player_died.connect(self.on_player_died)


func _process(delta: float) -> void:

    self.global_position = self.camera_target.global_position

    var target_fov = self.initial_camera_fov
    var target_pos = Vector3(0, self.spring_arm.position.y, self.spring_arm.position.z)

    if self.is_aiming && !self.aim_mode_forever_disabled:
        target_fov = self.aim_fov
        target_pos.x = self.aim_x_offset

    create_tween().tween_property(self.camera, "fov", target_fov, self.aim_transition_duration)
    create_tween().tween_property(self.spring_arm, "position", target_pos, self.aim_transition_duration)


func _unhandled_input(event) -> void:
    if event is InputEventMouseMotion:
        self.horizontal_pivot.rotate_y(deg_to_rad(-event.relative.x * self.horizontal_sensitivity))
        self.vertical_pivot.rotate_x(deg_to_rad(-event.relative.y * self.vertical_sensitivity))
        self.vertical_pivot.rotation.x = clamp(self.vertical_pivot.rotation.x, -PI / 2, PI / 2)


func get_camera_y_rotation() -> float:
    return self.horizontal_pivot.rotation.y


func set_aim_mode_enabled(is_enabled: bool) -> void:
    if is_enabled == self.is_aiming or self.aim_mode_forever_disabled:
        return
    self.is_aiming = is_enabled
    SignalBus.player_aim_mode_changed.emit(self.is_aiming)


func on_player_died() -> void:
    self.aim_mode_forever_disabled = true
    self.is_aiming = false
