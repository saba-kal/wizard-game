extends Control


func _ready():
    self.visible = false


func _process(delta):
    if Input.is_action_just_pressed("show_spell_craft_menu"):
        self.visible = !self.visible
        if self.visible:
            Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
        else:
            Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
