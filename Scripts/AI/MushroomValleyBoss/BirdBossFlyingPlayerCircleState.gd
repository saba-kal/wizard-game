extends BirdBossAIState

@export var max_state_time: float = 4.0

var time_in_state: float = 0


func get_type() -> Type:
    return Type.FLYING_PLAYER_CIRCLE


func enter_state() -> void:
    self.shared_data.pursue_target_ai.set_enabled(false)
    self.shared_data.fly_to_target_ai.set_enabled(true)
    self.shared_data.fly_to_target_ai.set_circular_flight_enabled(true)
    self.time_in_state = 0


func process_state(delta: float) -> void:

    self.shared_data.fly_to_target_ai.set_target(self.shared_data.player.global_position)
    if self.time_in_state >= self.max_state_time:
        self.transition_state.emit(Type.FLYING_SHORT_RANGE_ATTACK)

    self.time_in_state += delta


func exit_state() -> void:
    self.shared_data.fly_to_target_ai.set_circular_flight_enabled(false)


func is_flying() -> bool:
    return true
