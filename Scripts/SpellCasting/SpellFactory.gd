extends Node3D

@export var cast_time: float = 1.0

var blue_rune: BlueRune
var red_rune: RedRune
var yellow_rune: YellowRune
var available_spells: Array[Spell]
var player_mana: PlayerMana
var time_since_last_spell_cast: float = 0.0
var magic_circle: MagicCircle
var camera_is_aiming: bool = false


func _ready() -> void:
    SignalBus.rune_slots_changed.connect(self.on_rune_slots_changed)
    SignalBus.player_aim_mode_changed.connect(self.on_aim_mode_changed)
    for child in self.get_children():
        self.available_spells.append(child)
    self.player_mana = Util.get_child_node_of_type(self.get_parent(), PlayerMana)
    self.magic_circle = Util.get_child_node_of_type(self.get_parent(), MagicCircle)
    self.magic_circle.visible = false


func _process(delta: float) -> void:
    var runes_are_full = self.blue_rune != null && self.red_rune != null && self.yellow_rune != null
    if runes_are_full:
        var spell: Spell = self.get_spell()
        if spell != null:
            var is_spell_ready: bool = self.camera_is_aiming && self.time_since_last_spell_cast >= self.cast_time
            spell.set_indicator_visible(is_spell_ready)
            SignalBus.spell_ready_to_cast_updated.emit(is_spell_ready)
    self.time_since_last_spell_cast += delta


func _unhandled_input(event) -> void:
    if event.is_action("cast_spell") && event.is_pressed():
        self.cast_spell()


func on_rune_slots_changed(new_blue_rune: BlueRune, new_red_rune: RedRune, new_yellow_rune: YellowRune) -> void:
    self.blue_rune = new_blue_rune
    self.red_rune = new_red_rune
    self.yellow_rune = new_yellow_rune


func cast_spell() -> void:

    if !self.camera_is_aiming:
        return

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

    if self.time_since_last_spell_cast < self.cast_time:
        print("Cannot cast yet. Need to wait %.3f seconds" % (self.cast_time - self.time_since_last_spell_cast))
        return

    self.player_mana.consume_mana(mana_cost)
    self.time_since_last_spell_cast = 0
    self.magic_circle.reset_timer(self.cast_time)
    spell.cast_spell(self.blue_rune, self.red_rune, self.yellow_rune)
    SignalBus.spell_cast.emit(self.yellow_rune.type == YellowRune.YellowRuneType.SELF)


func get_spell() -> Spell:
    for spell in self.available_spells:
        if spell.supports_runes(self.blue_rune, self.red_rune, self.yellow_rune):
            return spell
    return null


func on_aim_mode_changed(is_aiming: bool) -> void:
    self.magic_circle.visible = is_aiming && self.blue_rune != null && self.red_rune != null && self.yellow_rune != null
    self.time_since_last_spell_cast = 0
    self.magic_circle.reset_timer(self.cast_time)
    self.camera_is_aiming = is_aiming
