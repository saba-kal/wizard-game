class_name BlueRune extends Rune

@export var type: BlueRuneType = BlueRuneType.FIRE

enum BlueRuneType {
    FIRE,
    ICE,
    CONDITION,
    CRATE
}


func get_type() -> Type:
    return Type.BLUE
