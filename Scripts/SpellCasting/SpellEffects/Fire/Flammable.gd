class_name Flammable extends Node3D


var duration: float = 5
var time_since_fire: float = 0
var fire_started: bool = false
var fire_source: Node3D
var un_duration: float = 5
var time_since_un_fire: float = 0
var un_fire_started: bool = false
var un_fire_source: Node3D
var status_health: StatusHealth


func _ready():
    self.status_health = Util.get_child_node_of_type(self.get_parent(), StatusHealth)


func _process(delta):
    if self.fire_started:
        process_fire(delta)
    if self.un_fire_started:
        process_un_fire(delta)

func process_fire(delta):
    self.time_since_fire += delta
    if self.time_since_fire >= self.duration:
        self.extinguish()
        self.time_since_fire = 0
        self.fire_started = false

func process_un_fire(delta):
    self.time_since_un_fire += delta
    if self.time_since_un_fire >= self.un_duration:
        self.un_extinguish()
        self.time_since_un_fire = 0
        self.un_fire_started = false

func start_fire(fire_duration: float, status_damage: float, source: Node3D):
    if self.status_health != null:
        self.status_health.take_damage(status_damage)
        if self.status_health.get_current_health() > 0:
            return
    self.fire_started = true
    self.duration = fire_duration
    self.fire_source = source
    self.light()

func start_un_fire(fire_duration: float, source: Node3D):
    self.un_fire_started = true
    self.un_duration = fire_duration
    self.un_fire_source = source
    self.un_light()


func light():
    pass # implmented by inherited classes


func extinguish():
    pass # implmented by inherited classes

func un_light():
    pass

func un_extinguish():
    pass
