class_name PlayerMana extends Node

@export var max_mana: float = 100
@export var mana_regen_rate: float = 5

var current_mana: float = 0


func _ready():
    self.current_mana = self.max_mana


func _process(delta):
    self.current_mana += self.mana_regen_rate * delta
    self.current_mana = clamp(self.current_mana, 0, self.max_mana)


func consume_mana(mana: float):
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
