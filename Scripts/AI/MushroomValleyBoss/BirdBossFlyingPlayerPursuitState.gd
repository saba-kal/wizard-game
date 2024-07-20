extends BirdBossAIState

@export var max_state_time: float = 10.0
@export var distance_until_state_change: float = 8.0

var time_in_state: float = 0


func get_type() -> Type:
    return Type.FLYING_PLAYER_PURSUIT


func enter_state() -> void:
    self.shared_data.pursue_target_ai.set_enabled(false)
    self.shared_data.fly_to_target_ai.set_enabled(true)
    self.time_in_state = 0


func process_state(delta: float) -> void:

    self.shared_data.fly_to_target_ai.set_target(self.shared_data.player.global_position)

    if self.reached_player():
        var random_state: Type = [Type.FLYING_PLAYER_CIRCLE, Type.FLYING_SHORT_RANGE_ATTACK].pick_random()
        self.transition_state.emit(random_state)
    elif self.time_in_state >= self.max_state_time:
        self.transition_state.emit(Type.FLYING_LOCATION_PURSUIT)

    self.time_in_state += delta


func exit_state() -> void:
    pass


func is_flying() -> bool:
    return true


func reached_player() -> bool:
    var distance_sqr_to_player: float = self.shared_data.character_body.global_position.distance_squared_to(self.shared_data.player.global_position)
    return distance_sqr_to_player <= self.distance_until_state_change * self.distance_until_state_change
