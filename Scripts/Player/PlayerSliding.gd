class_name PlayerSliding extends Area3D


@export var slip_factor: int = 300
@export var slip_duration: int = 10
@export var spell_effect_scene: PackedScene
@export var spawn_height: float = 3
@export var player_height_offset: float = 0

var sliding: bool = false
var slippery: bool = false
var global_gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var slip_time: float = 0
var player_movement: PlayerMovement
var third_person_camera: ThirdPersonCamera


func _ready():
    self.player_movement = Util.get_child_node_of_type(self.get_parent(), PlayerMovement)
    self.third_person_camera = Util.get_child_node_of_type(self.get_parent(), ThirdPersonCamera)
    self.area_entered.connect(self.on_area_entered)
    self.body_entered.connect(self.on_body_entered)
    self.area_exited.connect(self.on_area_exited)
    self.body_exited.connect(self.on_body_exited)

func _process(delta):
    if slippery:
        slip_time -= delta
        if(slip_time <= 0):
            slippery = false

func on_area_entered(area: Area3D):
    self.sliding = true

func on_body_entered(body: Node3D):
    self.sliding = true

func on_area_exited(area: Area3D):
    on_exit()

func on_body_exited(body: Node3D):
    on_exit()

func on_exit():
    if(!has_overlapping_areas() and !has_overlapping_bodies()):
        sliding = false

func is_sliding():
    return sliding or slippery


func _on_snowboard_spell_cast():
    var spell_effect: IceBoard = self.spell_effect_scene.instantiate()
    self.get_tree().root.add_child(spell_effect)
    spell_effect.global_position = self.global_position + Vector3(0, spawn_height, 0)
    player_movement.player_node.global_position.y += spawn_height + player_height_offset
    var rotation: float = third_person_camera.get_camera_y_rotation()
    var vec: Vector3 = Vector3(0, 0, -1).rotated(Vector3(0,1,0), rotation)
    vec *= spell_effect.target_speed
    vec += player_movement.get_velocity()
    player_movement.player_node.apply_floor_snap()
    spell_effect.linear_velocity = vec
    player_movement.get_sticky(spell_effect)
