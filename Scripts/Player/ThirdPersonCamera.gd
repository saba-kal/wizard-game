class_name ThirdPersonCamera extends Node3D

@export var camera_target: Node3D
@export var camera_mount: Node3D
@export var camera: Camera3D
@export var horizontal_sensitivity: float = 0.1
@export var vertical_sensitivity: float = 0.1
@export var aim_fov: float = 50
@export var aim_x_offset: float = 3

var initial_camera_fov = 60
var is_aiming = false


func _ready():
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    self.initial_camera_fov = self.camera.fov


func _process(delta):
    if Input.is_action_pressed("aim"):
        self.camera.fov = self.aim_fov
        self.camera.position.x = self.aim_x_offset
        self.is_aiming = true
    else:
        self.camera.fov = self.initial_camera_fov
        self.camera.position.x = 0
        self.is_aiming = false


func _unhandled_input(event):
    if event is InputEventMouseMotion:
        self.camera_target.rotate_y(deg_to_rad(-event.relative.x * self.horizontal_sensitivity))
        self.camera_mount.rotate_x(deg_to_rad(-event.relative.y * self.vertical_sensitivity))
