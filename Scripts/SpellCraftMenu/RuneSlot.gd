class_name RuneSlot extends Control

@export var rune_type: Rune.Type = Rune.Type.BLUE


var socketed_rune: Rune


func _can_drop_data(at_position, data):
    return self.socketed_rune == null


func _drop_data(at_position, data):
    var draggable_rune: DraggableRune = data["node"]
    var parent = draggable_rune.get_parent()
    if "socketed_rune" in parent:
        parent.socketed_rune = null
    draggable_rune.reparent(self, false)
    self.socketed_rune = draggable_rune.rune
