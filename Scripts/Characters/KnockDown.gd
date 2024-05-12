class_name KnockDown extends Node3D

signal knock_down_started()
signal knock_down_ended()

@export var knock_down_duration: float = 1.0

var is_knocked_down: bool = false
var time_since_knock_down_start: float = 0.0


func execute() -> void:
    if self.is_knocked_down:
        return # Is already knocked down.
    self.knock_down_started.emit()
    self.is_knocked_down = true
    self.time_since_knock_down_start = 0
    self.start_knock_down()


func _process(delta: float) -> void:
    if self.is_knocked_down && self.time_since_knock_down_start >= self.knock_down_duration:
        self.is_knocked_down = false
        self.knock_down_ended.emit()
        self.end_knock_down()
    elif self.is_knocked_down:
        self.time_since_knock_down_start += delta


func start_knock_down() -> void:
    pass # Implemented by child classes


func end_knock_down() -> void:
    pass # Implemented by child classes
