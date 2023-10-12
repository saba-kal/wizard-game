extends Control

var is_paused: bool = false


func _ready():
    self.resume_game()


func _process(delta):
    if Input.is_action_just_pressed("pause"):
        if self.is_paused:
            self.resume_game()
        else:
            self.pause_game()


func resume_game():
    self.get_tree().paused = false
    self.visible = false
    self.is_paused = false
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func pause_game():
    self.get_tree().paused = true
    self.visible = true
    self.is_paused = true
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func resume_game_mouse_visible():
    self.resume_game()
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
