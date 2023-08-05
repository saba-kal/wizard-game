class_name Rune extends TextureRect

@export var drag_preview_scene: PackedScene

func _get_drag_data(at_position):
    var data = {}
    data["node"] = self

    var drag_preview: TextureRect = self.drag_preview_scene.instantiate()
    drag_preview.texture = self.texture
    self.add_child(drag_preview)

    return data


