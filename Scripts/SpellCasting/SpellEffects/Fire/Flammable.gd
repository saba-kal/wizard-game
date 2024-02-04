class_name Flammable extends Node3D


var duration: float = 5
var time_since_fire: float = 0
var fire_started: bool = false
var fire_source: Node3D
var status_health: StatusHealth


func _ready():
    self.status_health = Util.get_child_node_of_type(self.get_parent(), StatusHealth)


func _process(delta):
    if !self.fire_started:
        return
    self.time_since_fire += delta
    if self.time_since_fire >= self.duration:
        self.extinguish()
        self.time_since_fire = 0
        self.fire_started = false


func start_fire(fire_duration: float, status_damage: float, source: Node3D):
    if self.status_health != null:
        self.status_health.take_damage(status_damage)
        if self.status_health.get_current_health() > 0:
            return
    self.fire_started = true
    self.duration = fire_duration
    self.fire_source = source
    self.light()


func light():
    pass # implmented by inherited classes


func extinguish():
    pass # implmented by inherited classes
