class_name QuestIcon extends Node

@onready var new_quest_icon: Node3D = $SpriteScaler/NewQuestIcon
@onready var quest_in_progress_icon: Node3D = $SpriteScaler/QuestInProgressIcon
@onready var quest_complete_icon: Node3D = $SpriteScaler/QuestCompleteIcon


func _ready() -> void:
    self.show_new_quest_icon()


func show_new_quest_icon() -> void:
    self.new_quest_icon.visible = true
    self.quest_in_progress_icon.visible = false
    self.quest_complete_icon.visible = false


func show_quest_in_progress_icon() -> void:
    self.new_quest_icon.visible = false
    self.quest_in_progress_icon.visible = true
    self.quest_complete_icon.visible = false


func show_quest_complete_icon() -> void:
    self.new_quest_icon.visible = false
    self.quest_in_progress_icon.visible = false
    self.quest_complete_icon.visible = true
