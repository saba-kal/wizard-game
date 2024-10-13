extends Area3D

func _ready() -> void:
    self.body_entered.connect(self.on_body_entered)


func on_body_entered(body: Node3D) -> void:
    if body.is_in_group("Player"):
        SignalBus.quest_item_collected.emit(self)
        self.queue_free()
