class_name YellowRune extends Rune

@export var type: YellowRuneType = YellowRuneType.GROUND

enum YellowRuneType {
    GROUND,
    SELF
}


func get_type() -> Type:
    return Type.YELLOW
