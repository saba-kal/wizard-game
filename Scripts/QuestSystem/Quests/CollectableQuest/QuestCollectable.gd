class_name QuestCollectable extends Area3D

@export var type: String

var is_collected: bool = false


func _ready() -> void:
    self.body_entered.connect(self.on_body_entered)


func on_body_entered(body: Node3D) -> void:

    # don't collect self twice
    # Prefer this method over deleting the collectable because it will still
    # need to be referenced by other scripts.
    if self.is_collected:
        return

    if body is PlayerController:
        self.is_collected = true
        self.visible = false
        SignalBus.quest_collectable_obtained.emit(self)
