class_name PlayerMana extends Node

@export var max_mana: float = 100
@export var base_mana_regen_rate: float = 0
@export var mana_regen_rate: float = 10

@onready var particles: GPUParticles3D = $GPUParticles3D


var current_mana: float = 0
var regen_active: bool = false


func _ready() -> void:
    self.current_mana = self.max_mana
    self.particles.emitting = false


func _process(delta: float) -> void:

    var regen: float = self.base_mana_regen_rate

    if Input.is_action_pressed("regen_mana") && self.current_mana < self.max_mana:
        regen += self.mana_regen_rate
        if !self.regen_active:
            self.regen_active = true
            SignalBus.player_mana_regen_changed.emit(self.regen_active)
    elif self.regen_active:
        self.regen_active = false
        SignalBus.player_mana_regen_changed.emit(self.regen_active)

    self.particles.emitting = self.regen_active
    self.current_mana += regen * delta
    self.current_mana = clamp(self.current_mana, 0, self.max_mana)


func consume_mana(mana: float) -> void:
    if self.current_mana >= mana:
        self.current_mana -= mana
    else:
        printerr("Not enough mana to cast spell. Current mana: %d, Spell cost: %d" % [self.current_mana, mana])


func calculate_mana_cost(runes: Array[Rune]) -> float:
    var cost: float = 0
    for rune in runes:
        cost += rune.mana_cost
    for rune in runes:
        cost *= rune.mana_multiplier
    return cost
