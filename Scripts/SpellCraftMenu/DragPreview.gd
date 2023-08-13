class_name DragPreview extends TextureRect


func _process(delta):
    self.global_position = self.get_global_mouse_position() - self.get_rect().size / 2
    if Input.is_action_just_released("mouse_left"):
        self.queue_free()
