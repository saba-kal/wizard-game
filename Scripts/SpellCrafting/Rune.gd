class_name Rune extends Resource

@export var texture: Texture2D = null
@export var mana_cost: float = 10
@export var mana_multiplier: float = 1

enum Type {BLUE, RED, YELLOW}


func get_type() -> Type:
    return Type.BLUE


func equals(other: Rune) -> bool:
    return self.get_type() == other.get_type()
