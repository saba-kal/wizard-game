class_name RuneSlot extends Control

signal socketed_rune_changed(rune_slot: RuneSlot)

@export var rune_type: Rune.Type = Rune.Type.BLUE

var socketed_rune: Rune


func _can_drop_data(at_position, data):
    var draggable_rune: DraggableRune = data["node"]
    return self.socketed_rune == null && self.rune_type == draggable_rune.rune.get_type()


func _drop_data(at_position, data):
    var draggable_rune: DraggableRune = data["node"]
    var parent = draggable_rune.get_parent()
    if "remove_socketed_rune" in parent:
        parent.remove_socketed_rune()
    draggable_rune.reparent(self, false)
    self.socketed_rune = draggable_rune.rune
    self.socketed_rune_changed.emit(self)


func remove_socketed_rune():
    self.socketed_rune = null
    self.socketed_rune_changed.emit(self)
