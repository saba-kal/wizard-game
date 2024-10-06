class_name BirdBossAIState extends AIState

signal transition_state(to_state: Type)

enum Type {
    GROUNDED_IDLE,
    GROUNDED_PLAYER_PURSUIT,
    GROUNDED_LOCATION_PURSUIT,
    GROUNDED_SHORT_RANGE_ATTACK,
    GROUNDED_MEDIUM_RANGE_ATTACK,
    GROUNDED_LONG_RANGE_ATTACK,
    GROUNDED_KNOCKED_OUT,
    FLYING_IDLE,
    FLYING_PLAYER_PURSUIT,
    FLYING_PLAYER_CIRCLE,
    FLYING_LOCATION_PURSUIT,
    FLYING_SHORT_RANGE_ATTACK,
    FLYING_MEDIUM_RANGE_ATTACK,
    FLYING_LONG_RANGE_ATTACK,
    FLYING_FALL,
    FLYING_RISE_UP,
    FLYING_COME_DOWN,
    DEAD 
}

@export var action_points: int = 0

var shared_data: MushroomBirdBossAI.BirdBossAISharedData
var shared_functions: MushroomBirdBossAI.BirdBossAISharedFunctions


func init_state(
    data: MushroomBirdBossAI.BirdBossAISharedData, 
    functions: MushroomBirdBossAI.BirdBossAISharedFunctions) -> void:
    self.shared_data = data
    self.shared_functions = functions


func get_type() -> Type:
    return Type.DEAD # should be implemented by inhereting classes.


func is_flying() -> bool:
    return false # should be implemented by inhereting classes.
