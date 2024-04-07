extends Node

@export var open_spell_craft_label: RichTextLabel
@export var aim_label: RichTextLabel
@export var cast_spell_label: RichTextLabel
@export var mana_regen_label: RichTextLabel

var collected_runes: int = 0
var runes_collected: bool = false
var runes_socketed: bool = false
var spell_was_casted: bool = false


func _ready() -> void:
    self.open_spell_craft_label.visible = false
    self.aim_label.visible = false
    self.cast_spell_label.visible = false
    self.mana_regen_label.visible = false

    SignalBus.rune_collected.connect(self.on_rune_collected)
    SignalBus.rune_slots_changed.connect(self.on_rune_slots_changed)
    SignalBus.spell_craft_menu_opened.connect(self.on_spell_craft_menu_opened)
    SignalBus.spell_craft_menu_closed.connect(self.on_spell_craft_menu_closed)
    SignalBus.spell_ready_to_cast_updated.connect(self.on_spell_ready_to_cast_updated)
    SignalBus.spell_cast.connect(self.on_spell_cast)
    SignalBus.player_mana_regen_changed.connect(self.on_player_mana_regen_changed)


func on_rune_collected(_rune: Rune) -> void:
    self.collected_runes += 1
    if self.collected_runes >= 3:
        self.open_spell_craft_label.visible = true
        self.runes_collected = true


func on_rune_slots_changed(blue_rune: BlueRune, red_rune: RedRune, yellow_rune: YellowRune) -> void:
    if blue_rune != null && red_rune != null && yellow_rune != null:
        self.open_spell_craft_label.visible = false
        self.aim_label.visible = true
        self.runes_socketed = true


func on_spell_craft_menu_opened() -> void:
    self.visible = false


func on_spell_craft_menu_closed() -> void:
    self.visible = true


func on_spell_ready_to_cast_updated(is_spell_ready_to_cast: bool) -> void:
    if self.spell_was_casted:
        return
    if is_spell_ready_to_cast:
        self.aim_label.visible = false
        self.cast_spell_label.visible = true
    else:
        self.aim_label.visible = true
        self.cast_spell_label.visible = false


func on_spell_cast(_targets_self: bool) -> void:
    self.aim_label.visible = false
    self.cast_spell_label.visible = false
    self.mana_regen_label.visible = true
    self.spell_was_casted = true


func on_player_mana_regen_changed(is_mana_regen_on: bool) -> void:
    if !self.spell_was_casted:
        return
    # Tutorial is complete. Destroy self
    self.queue_free()
