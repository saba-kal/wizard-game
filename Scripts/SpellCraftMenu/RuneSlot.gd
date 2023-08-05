class_name RuneSlot extends TextureRect

var socketed_rune: Rune


func _can_drop_data(at_position, data):
    return self.socketed_rune == null


func _drop_data(at_position, data):
    var rune: Rune = data["node"]
    rune.reparent(self, false)
    rune.position = Vector2.ZERO
    rune.anchor_right = 0.45
    rune.anchor_bottom = 0.45
    self.socketed_rune = rune
