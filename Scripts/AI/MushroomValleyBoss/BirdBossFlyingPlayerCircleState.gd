extends BirdBossAIState

@export var flying_height: float = 5.0
@export var max_state_time: float = 10.0

var time_in_state: float = 0


func get_type() -> Type:
    return Type.FLYING_PLAYER_CIRCLE


func enter_state() -> void:
    self.pursue_target_ai.set_enabled(false)
    self.fly_to_target_ai.set_enabled(true)
    self.fly_to_target_ai.set_circular_flight_enabled(true)
    self.time_in_state = 0


func process_state(delta: float) -> void:

    self.fly_to_target_ai.set_target(self.player.global_position + Vector3(0, self.flying_height, 0))
    var distance_sqr_to_player: float = self.character_body.global_position.distance_squared_to(self.player.global_position)
    if self.time_in_state >= self.max_state_time:
        self.transition_state.emit(Type.GROUNDED_PLAYER_PURSUIT)

    self.time_in_state += delta


func exit_state() -> void:
    self.fly_to_target_ai.set_circular_flight_enabled(false)
