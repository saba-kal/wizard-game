class_name CollectableQuest extends Quest

@export var collectable_type: String
@export var amount_to_collect: int = 5
@export var objective_text: String

var amount_collected: int = 0


func _ready() -> void:
    super._ready()
    SignalBus.quest_collectable_obtained.connect(self.on_quest_collectable_obtained)


func on_quest_collectable_obtained(collectable: QuestCollectable) -> void:
    if collectable.type == self.collectable_type:
        self.amount_collected += 1
        SignalBus.quest_progress_updated.emit(self)
        if self.is_completed():
            self.complete_quest()


func is_completed() -> bool:
    return self.amount_collected >= self.amount_to_collect


func get_quest_objective_text() -> String:
    return self.objective_text


func get_quest_progress_text() -> String:
    return "%d/%d %ss collected" % [self.amount_collected, self.amount_to_collect, self.collectable_type]
