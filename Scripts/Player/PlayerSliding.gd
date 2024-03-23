class_name PlayerSliding extends Area3D

@export var slip_factor: int = 300
@export var slip_duration: int = 10

var sliding: bool = false
var slippery: bool = false
var player_movement: PlayerMovement
var global_gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var slip_time: float = 0



func _ready():
    self.player_movement = Util.get_child_node_of_type(self.get_parent(), PlayerMovement)
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
    slippery = true
    slip_time = slip_duration
