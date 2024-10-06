extends Node

var runes: Array[Rune] = []


func _ready() -> void:
    SignalBus.rune_collected.connect(self.on_rune_collected)


func on_rune_collected(new_rune: Rune) -> void:
    self.runes.append(new_rune)
