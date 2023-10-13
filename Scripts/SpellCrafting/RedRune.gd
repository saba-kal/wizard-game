class_name RedRune extends Rune

@export var type: RedRuneType = RedRuneType.DETRIMENT

enum RedRuneType {
    DETRIMENT,
    BENEFIT
}


func get_type() -> Type:
    return Type.RED


func equals(other: Rune) -> bool:
    return super.equals(other) && self.type == other.type
