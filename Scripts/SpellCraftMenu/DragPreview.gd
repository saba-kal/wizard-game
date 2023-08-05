extends TextureRect


func _process(delta):
    self.global_position = self.get_global_mouse_position()
    if Input.is_action_just_released("mouse_left"):
        self.queue_free()
