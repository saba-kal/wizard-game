extends Control

@export var starting_runes: Array[Rune]
@export var blue_rune_container: RuneContainer
@export var red_rune_container: RuneContainer
@export var yellow_rune_container: RuneContainer


func _ready():
    for rune in self.starting_runes:
        match rune.get_type():
            Rune.Type.BLUE:
                self.blue_rune_container.add_rune(rune)
            Rune.Type.RED:
                self.red_rune_container.add_rune(rune)
            Rune.Type.YELLOW:
                self.yellow_rune_container.add_rune(rune)
