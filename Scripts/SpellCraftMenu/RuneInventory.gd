extends Control

@export var blue_rune_container: RuneContainer
@export var red_rune_container: RuneContainer
@export var yellow_rune_container: RuneContainer


func _ready():
    for rune in PlayerData.runes:
        match rune.get_type():
            Rune.Type.BLUE:
                self.blue_rune_container.add_rune(rune)
            Rune.Type.RED:
                self.red_rune_container.add_rune(rune)
            Rune.Type.YELLOW:
                self.yellow_rune_container.add_rune(rune)
