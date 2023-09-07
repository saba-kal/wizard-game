class_name Flammable extends Node3D


var duration: float = 5
var time_since_fire: float = 0
var fire_started: bool = false
var fire_source: Node3D


func _process(delta):
    if !self.fire_started:
        return
    self.time_since_fire += delta
    if self.time_since_fire >= self.duration:
        self.extinguish()
        self.time_since_fire = 0
        self.fire_started = false


func start_fire(fire_duration: float, source: Node3D):
    self.fire_started = true
    self.duration = fire_duration
    self.fire_source = source
    self.light()


func light():
    pass # implmented by inherited classes


func extinguish():
    pass # implmented by inherited classes
