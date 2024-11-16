class_name DraggableRune extends TextureRect

@export var drag_preview_scene: PackedScene
@onready var sub_viewport: SubViewport = $SubViewport

var rune: Rune

func _ready() -> void:
    if(rune.visual):
        var node: Node = rune.visual.instantiate()
        node.position.x = -1
        if(node is VisualInstance3D):
            node.layers = 2
        var instances = Util.get_child_nodes_of_type(node, VisualInstance3D)
        for instance: VisualInstance3D in instances:
            instance.layers = 2
        sub_viewport.add_child(node)
    else:
        print("Rune could not be shown")

func _get_drag_data(at_position):
    var data = {}
    data["node"] = self

    var drag_preview: DragPreview = self.drag_preview_scene.instantiate()
    drag_preview.texture = texture
    self.add_child(drag_preview)

    return data
