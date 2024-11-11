class_name DraggableRune extends TextureRect

@export var drag_preview_scene: PackedScene

var rune: Rune



func _get_drag_data(at_position):
    var data = {}
    data["node"] = self

    var drag_preview: DragPreview = self.drag_preview_scene.instantiate()
    drag_preview.texture = texture
    self.add_child(drag_preview)

    return data
