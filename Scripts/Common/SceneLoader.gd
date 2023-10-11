extends Node

@export var scene_to_load: PackedScene


func load_scene():
    self.get_tree().change_scene_to_packed(self.scene_to_load)
