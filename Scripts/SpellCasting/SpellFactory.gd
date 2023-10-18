extends Node3D

var blue_rune: BlueRune
var red_rune: RedRune
var yellow_rune: YellowRune
var available_spells: Array[Spell]
var player_mana: PlayerMana


func _ready():
    SignalBus.rune_slots_changed.connect(self.on_rune_slots_changed)
    for child in self.get_children():
        self.available_spells.append(child)
    self.player_mana = Util.get_child_node_of_type(self.get_parent(), PlayerMana)


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

    var spell = self.get_spell()
    if spell == null:
        print("Unable to find spell for rune types %d, %d, %d" % [self.blue_rune.type, self.red_rune.type, self.yellow_rune.type])
        return

    var mana_cost = self.player_mana.calculate_mana_cost([self.blue_rune, self.red_rune, self.yellow_rune])
    if mana_cost > self.player_mana.current_mana:
        print("Not enough mana to cast spell")
        return

    self.player_mana.consume_mana(mana_cost)
    spell.cast_spell(self.blue_rune, self.red_rune, self.yellow_rune)


func get_spell() -> Spell:
    for spell in self.available_spells:
        if spell.supports_runes(self.blue_rune, self.red_rune, self.yellow_rune):
            return spell
    return null
