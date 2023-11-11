@tool
class_name RopeBridge extends Node3D

@export var is_broken: bool:
    get:
        return self.bridge_is_broken
    set(value):
        self.set_is_broken(value)

var bridge_is_broken = true


func _ready():
    self.is_broken = bridge_is_broken


func set_is_broken(broken: bool):
    if self.bridge_is_broken != broken:
        self.bridge_is_broken = broken
        self.animate_bridge_state()


func animate_bridge_state():
    if self.bridge_is_broken:
        $RopeBridge/AnimationPlayer.play("Break")
        $RepairedStaticBody3D.process_mode = Node.PROCESS_MODE_DISABLED
        $BrokenStaticBody3D.process_mode = Node.PROCESS_MODE_INHERIT
    else:
        $RopeBridge/AnimationPlayer.play("Repair")
        $RepairedStaticBody3D.process_mode = Node.PROCESS_MODE_INHERIT
        $BrokenStaticBody3D.process_mode = Node.PROCESS_MODE_DISABLED
