class_name YellowRune extends Rune

@export var type: YellowRuneType = YellowRuneType.GROUND

enum YellowRuneType {
    GROUND,
    SELF
}


func get_type() -> Type:
    return Type.YELLOW


func equals(other: Rune) -> bool:
    return super.equals(other) && self.type == other.type
