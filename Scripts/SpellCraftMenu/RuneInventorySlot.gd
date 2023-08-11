extends Control

@export var draggable_rune_scene: PackedScene

var rune_type: Rune.Type = Rune.Type.BLUE
var socketed_rune: Rune


func add_rune(rune: Rune):
    if self.socketed_rune != null:
        printerr("Cannot add rune to inventory slot because another rune already exists")
        return
    var draggable_rune: DraggableRune = self.draggable_rune_scene.instantiate()
    draggable_rune.rune = rune
    self.socketed_rune = rune
    self.add_child(draggable_rune)


func _can_drop_data(at_position, data):
    var draggable_rune: DraggableRune = data["node"]
    var rune: Rune = draggable_rune.rune
    return self.socketed_rune == null && self.rune_type == rune.get_type()


func _drop_data(at_position, data):
    var draggable_rune: DraggableRune = data["node"]
    var parent = draggable_rune.get_parent()
    if "socketed_rune" in parent:
        parent.socketed_rune = null
    draggable_rune.reparent(self, false)
    draggable_rune.position = Vector2.ZERO
    self.socketed_rune = draggable_rune.rune
