extends Node3D

var blue_rune: BlueRune
var red_rune: RedRune
var yellow_rune: YellowRune
var available_spells: Array[Spell]


func _ready():
    SignalBus.rune_slots_changed.connect(self.on_rune_slots_changed)
    for child in self.get_children():
        self.available_spells.append(child)


func _unhandled_input(event):
    if event.is_action("cast_spell") && event.is_pressed():
        self.cast_spell()


func on_rune_slots_changed(blue_rune: BlueRune, red_rune: RedRune, yellow_rune: YellowRune):
    self.blue_rune = blue_rune
    self.red_rune = red_rune
    self.yellow_rune = yellow_rune


func cast_spell():
    if self.blue_rune == null || self.red_rune == null || self.yellow_rune == null:
        print("Cannot cast spell until all rune slots are full")
        return

    for spell in self.available_spells:
        if spell.supports_runes(self.blue_rune, self.red_rune, self.yellow_rune):
            spell.cast_spell(self.blue_rune, self.red_rune, self.yellow_rune)
            return
    print("Unable to find spell for rune types %d, %d, %d" % 
        [self.blue_rune.type, self.red_rune.type, self.yellow_rune.type])
