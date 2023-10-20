class_name MagicCircle extends Node3D


@export var rotation_speed = 1
@export var rune_rotation_speed = 1.5


var runes: Array[Node3D] = []
var init_duration: float = 1.0
var timer: float = 0.0
var rotation_speed_multiplier: float = 1.0


func _ready():
    for child in self.get_children():
        self.runes.append(child)


func _process(delta):
    self.rotate_z(self.rotation_speed * self.rotation_speed_multiplier * delta)
    var all_visible: bool = true
    for i in range(len(self.runes)):
        var appear_time = (i + 1) / float(len(self.runes)) * self.init_duration - 0.1
        self.runes[i].visible = appear_time <= self.timer
        all_visible = all_visible && self.runes[i].visible
        self.runes[i].rotate_z(-self.rune_rotation_speed * self.rotation_speed_multiplier * delta)
    
    if all_visible:
        self.rotation_speed_multiplier = 1.0
    else:
        self.rotation_speed_multiplier = 10.0

    self.timer += delta


func reset_timer(duration: float):
    self.init_duration = duration
    self.timer = 0
