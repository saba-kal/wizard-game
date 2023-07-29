extends Node3D

@export var camera_target: Node3D
@export var camera_mount: Node3D
@export var horizontal_sensitivity: float = 0.1
@export var vertical_sensitivity: float = 0.1


func _ready():
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _process(delta):
    pass


func _input(event):
    if event is InputEventMouseMotion:
        self.camera_target.rotate_y(deg_to_rad(-event.relative.x * self.horizontal_sensitivity))
        self.camera_mount.rotate_x(deg_to_rad(-event.relative.y * self.vertical_sensitivity))
