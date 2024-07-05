extends Button

@export var transition_to: SceneLoader.SceneType = SceneLoader.SceneType.MAIN_MENU


func _ready() -> void:
    self.pressed.connect(self.on_button_pressed)


func on_button_pressed() -> void:
    SceneLoader.load_scene(self.transition_to)
