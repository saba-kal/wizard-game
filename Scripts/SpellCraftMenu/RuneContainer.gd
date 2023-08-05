extends Control

@onready var grid_container = $GridContainer


func _can_drop_data(at_position, data):
    return true


func _drop_data(at_position, data):
    var rune: Rune = data["node"]
    var parent = rune.get_parent()
    if "socketed_rune" in parent:
        parent.socketed_rune = null
    rune.reparent(self.grid_container, false)
