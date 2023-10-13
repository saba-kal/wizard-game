extends Button

@export var transition_to: SceneLoader.SceneType = SceneLoader.SceneType.MAIN_MENU


func _ready():
    self.pressed.connect(self.on_button_pressed)


func on_button_pressed():
    SceneLoader.load_scene(self.transition_to)
