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

var initial_camera_fov = 60
var is_aiming = false
var aim_mode_disabled: bool = false


func _ready():
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    self.initial_camera_fov = self.camera.fov
    self.spring_arm.add_excluded_object(self.camera_target)
    SignalBus.player_died.connect(self.on_player_died)


func _process(delta: float):

    self.global_position = self.camera_target.global_position
    
    var target_fov = self.initial_camera_fov
    var target_pos = Vector3(0, self.spring_arm.position.y, self.spring_arm.position.z)

    var old_is_aiming = self.is_aiming
    if Input.is_action_pressed("aim") && !self.aim_mode_disabled:
        target_fov = self.aim_fov
        target_pos.x = self.aim_x_offset
        self.is_aiming = true
    else:
        self.is_aiming = false
    if old_is_aiming != self.is_aiming:
        SignalBus.player_aim_mode_changed.emit(self.is_aiming)

    create_tween().tween_property(self.camera, "fov", target_fov, self.aim_transition_duration)
    create_tween().tween_property(self.spring_arm, "position", target_pos, self.aim_transition_duration)


func _unhandled_input(event):
    if event is InputEventMouseMotion:
        self.horizontal_pivot.rotate_y(deg_to_rad(-event.relative.x * self.horizontal_sensitivity))
        self.vertical_pivot.rotate_x(deg_to_rad(-event.relative.y * self.vertical_sensitivity))
        self.vertical_pivot.rotation.x = clamp(self.vertical_pivot.rotation.x, -PI / 2, PI / 2)


func get_camera_y_rotation() -> float:
    return self.horizontal_pivot.rotation.y


func on_player_died() -> void:
    self.aim_mode_disabled = true
