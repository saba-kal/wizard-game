class_name Rune extends Resource

@export var texture: Texture2D = null

enum Type {BLUE, RED, YELLOW}


func get_type() -> Type:
    return Type.BLUE
