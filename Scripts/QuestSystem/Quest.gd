# This is an abstract class that should be inherited by specific types of quests. See CollectableQuest.gs as an example
class_name Quest extends Area3D

@export var quest_icon: QuestIcon
@export var start_dialog: Dialog
@export var reward_dialog: Dialog
@export var reward: Area3D

var is_started: bool = false
var reward_ready: bool = false
var reward_obtained: bool = false
var active_dialog: Dialog


func _ready() -> void:
    self.body_entered.connect(self.on_body_entered)
    self.body_exited.connect(self.on_body_exited)
    self.quest_icon.show_new_quest_icon()


func interact() -> bool:
    if self.is_started && !self.reward_ready || self.reward_obtained:
        return true
    activate_dialog(start_dialog)
    var done: bool = active_dialog.advance_dialog()
    if  self.reward_ready:
        self.give_reward()
    elif self.is_completed():
        self.complete_quest()
    elif done:
        self.start_quest()
    return done


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
    self.quest_icon.visible = false
    self.reward_obtained = true
    SignalBus.quest_reward_obtained.emit(self)
    reward.visible = true
    reward.monitoring = true
    activate_dialog(reward_dialog)
    active_dialog.advance_dialog()


func on_body_entered(body: Node3D) -> void:
    if body is PlayerController:
        SignalBus.player_entered_quest_giver_area.emit(self)


func on_body_exited(body: Node3D) -> void:
    if body is PlayerController:
        SignalBus.player_exited_quest_giver_area.emit(self)
        if(active_dialog):
            active_dialog.visible = false

func activate_dialog(dialog: Dialog) -> void:
    if(active_dialog):
            active_dialog.visible = false
    active_dialog = dialog
    active_dialog.visible = true
    active_dialog.activate()

func get_quest_objective_text() -> String:
    # this method should be implemented by child classes.
    return "NOT IMPLEMENTED"


func get_quest_progress_text() -> String:
    # this method should be implemented by child classes.
    return "NOT IMPLEMENTED"
