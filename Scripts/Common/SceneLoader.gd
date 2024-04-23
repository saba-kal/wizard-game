extends Node

enum SceneType {
    MAIN_MENU = 0,
    HUB = 1,
    MUSHROOM_FOREST = 2,
    TUTORIAL = 3,
    TEST = 4
}

var scenes: Array[String] = [
    "res://Scenes/MainMenu.tscn",
    "res://Scenes/Levels/Hub.tscn",
    "res://Scenes/Levels/MushroomForest.tscn",
    "res://Scenes/Levels/TutorialLevel.tscn",
    "res://Scenes/Levels/Dev/SabaTestLevel.tscn"
]

var load_started: bool = false
var load_screen: PackedScene = preload("res://Scenes/UI/LoadScreen.tscn")
var load_screen_inst: Node
var scene_to_load: String


func load_scene(scene_type: SceneType) -> void:
    self.load_started = true
    self.load_screen_inst = self.load_screen.instantiate()
    self.get_tree().root.add_child(self.load_screen_inst)
    self.scene_to_load = self.scenes[scene_type]
    ResourceLoader.load_threaded_request(self.scene_to_load)


func _process(delta: float) -> void:
    if !self.load_started:
        return
    var load_status: int = ResourceLoader.load_threaded_get_status(self.scene_to_load)
    if load_status == 3: #ThreadLoadStatus.THREAD_LOAD_LOADED
        var new_scene: PackedScene = ResourceLoader.load_threaded_get(self.scene_to_load)
        self.load_screen_inst.queue_free()
        self.get_tree().change_scene_to_packed(new_scene)
