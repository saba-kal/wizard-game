extends Control

@onready var quest_progress_label: Label = $QuestProgressLabel

var active_quests: Array[Quest] = []


func _ready() -> void:
    self.visible = false
    SignalBus.quest_started.connect(self.on_quest_started)
    SignalBus.quest_reward_obtained.connect(self.on_quest_reward_obtained)
    SignalBus.quest_progress_updated.connect(self.on_quest_progress_updated)


func on_quest_started(quest: Quest) -> void:
    self.visible = true
    self.active_quests.append(quest)
    self.update_quest_progress_text()


func on_quest_reward_obtained(quest: Quest) -> void:
    Util.remove_elem(self.active_quests, quest)
    if len(self.active_quests) == 0:
        self.visible = false
    else:
        self.update_quest_progress_text()


func on_quest_progress_updated(quest: Quest) -> void:
    self.update_quest_progress_text()


func update_quest_progress_text() -> void:
    self.quest_progress_label.text = ""
    for quest: Quest in self.active_quests:
        self.quest_progress_label.text += "%s\n- %s\n\n" % [
            quest.get_quest_objective_text(),
            quest.get_quest_progress_text()
        ]
