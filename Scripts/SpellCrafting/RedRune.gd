class_name RedRune extends Rune

@export var type: RedRuneType = RedRuneType.DETRIMENT

enum RedRuneType {
    DETRIMENT
}

func get_type() -> Type:
    return Type.RED
