# This is an abstract class that should be inherited by specific types of quests. See CollectableQuest.gs as an example
class_name Quest extends Area3D

@export var quest_icon: QuestIcon

var is_started: bool = false
var reward_ready: bool = false
var reward_obtained: bool = false


func _ready() -> void:
    self.body_entered.connect(self.on_body_entered)
    self.body_exited.connect(self.on_body_exited)
    self.quest_icon.show_new_quest_icon()


func interact() -> void:
    if self.is_started && !self.reward_ready || self.reward_obtained:
        return

    if self.reward_ready:
        self.give_reward()
    elif self.is_completed():
        self.complete_quest()
    else:
        self.start_quest()


func start_quest() -> void:
    SignalBus.quest_started.emit(self)
    self.quest_icon.show_quest_in_progress_icon()
    self.is_started = true


func is_completed() -> bool:
    # this method should be implemented by child classes.
    return false


func complete_quest() -> void:
    # this method should be called by child classes. See CollectableQuest.gs as an example
    SignalBus.quest_completed.emit(self)
    self.quest_icon.show_quest_complete_icon()
    self.reward_ready = true


func give_reward() -> void:
    # TODO give actual reward
    self.quest_icon.visible = false
    self.reward_obtained = true
    SignalBus.quest_reward_obtained.emit(self)
    print("Quest reward obtained!")


func on_body_entered(body: Node3D) -> void:
    if body is PlayerController:
        SignalBus.player_entered_quest_giver_area.emit(self)


func on_body_exited(body: Node3D) -> void:
    if body is PlayerController:
        SignalBus.player_exited_quest_giver_area.emit(self)


func get_quest_objective_text() -> String:
    # this method should be implemented by child classes.
    return "NOT IMPLEMENTED"


func get_quest_progress_text() -> String:
    # this method should be implemented by child classes.
    return "NOT IMPLEMENTED"
