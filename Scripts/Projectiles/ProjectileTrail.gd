extends Node3D

@export var linger_time: float = 5.0

var follow_target: Node3D
var time_since_target_destruction: float = 0

func _ready():
    self.follow_target = self.get_parent()
    self.call_deferred("remove_parent")


func remove_parent():
    self.reparent(self.get_tree().root)


func _process(delta):
    if is_instance_valid(self.follow_target):
        self.global_position = self.follow_target.global_position
    else:
        self.time_since_target_destruction += delta
    if self.time_since_target_destruction > self.linger_time:
        self.queue_free()
