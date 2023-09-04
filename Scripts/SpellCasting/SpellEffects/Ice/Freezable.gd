class_name Freezable extends Node3D

var duration: float = 5
var time_since_frozen: float = 0
var freeze_started: bool = false
var freeze_source: Node3D


func _process(delta):
    if !self.freeze_started:
        return
    self.time_since_frozen += delta
    if self.time_since_frozen >= self.duration:
        self.unfreeze()
        self.time_since_frozen = 0
        self.freeze_started = false


func start_freeze(duration: float, source: Node3D):
    self.freeze_started = true
    self.duration = duration
    self.freeze_source = source
    self.freeze()


func freeze():
    pass # implmented by inherited classes


func unfreeze():
    pass # implmented by inherited classes
