extends Node

var runes: Array[Rune] = []


func _ready():
    SignalBus.rune_collected.connect(self.on_rune_collected)


func on_rune_collected(rune: Rune):
    self.runes.append(rune)
