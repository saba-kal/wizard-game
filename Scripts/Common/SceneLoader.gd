class_name SceneLoader extends Node

enum SceneType {
    MainMenu = 0,
    Hub = 1,
    MushroomForest = 2
}

@export var scene_to_load: SceneType = SceneType.MainMenu

static var scenes: Array[String] = [
    "res://Scenes/MainMenu.tscn",
    "res://Scenes/Levels/Hub.tscn",
    "res://Scenes/Levels/MushroomForest.tscn"
]


func load_scene():
    self.get_tree().change_scene_to_file(self.scenes[self.scene_to_load])
