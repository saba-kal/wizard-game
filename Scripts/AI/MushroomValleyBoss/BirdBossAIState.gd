class_name BirdBossAIState extends AIState

signal transition_state(to_state: Type)

enum Type {
    GROUNDED_IDLE,
    GROUNDED_PLAYER_PURSUIT,
    GROUNDED_LOCATION_PURSUIT,
    GROUNDED_SHORT_RANGE_ATTACK,
    GROUNDED_LONG_RANGE_ATTACK,
    FLYING_IDLE,
    FLYING_PLAYER_PURSUIT,
    FLYING_PLAYER_CIRCLE,
    FLYING_LOCATION_PURSUIT,
    FLYING_SHORT_RANGE_ATTACK,
    FLYING_LONG_RANGE_ATTACK,
    DEAD 
}

var character_body: CharacterBody3D
var pursue_target_ai: PursueTargetAI
var fly_to_target_ai: FlyToTargetAI
var player: Node3D
var hover_positions: Array[Marker3D] = []
var start_position: Vector3


func init_state(
    char_body: CharacterBody3D,
    pursue_ai: PursueTargetAI,
    fly_ai: FlyToTargetAI,
    plr: Node3D,
    hov_positions: Array[Marker3D]
) -> void:
    self.character_body = char_body
    self.pursue_target_ai = pursue_ai
    self.fly_to_target_ai = fly_ai
    self.player = plr
    self.hover_positions = hov_positions
    self.start_position = self.character_body.global_position


func get_type() -> Type:
    return Type.DEAD # should be implemented by inhereting classes.

