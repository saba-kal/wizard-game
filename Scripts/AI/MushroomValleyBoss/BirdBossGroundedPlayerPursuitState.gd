extends BirdBossAIState

@export var short_range_attack_radius: float = 2.5
@export var long_range_attack_distance: float = 15.0
@export var max_state_time: float = 10.0

var time_in_state: float = 0


func get_type() -> Type:
    return Type.GROUNDED_PLAYER_PURSUIT


func enter_state() -> void:
    self.pursue_target_ai.set_enabled(true)
    self.fly_to_target_ai.set_enabled(false)
    self.time_in_state = 0


func process_state(delta: float) -> void:

    self.pursue_target_ai.set_target(self.player.global_position)
    var distance_sqr_to_player: float = self.character_body.global_position.distance_squared_to(self.player.global_position)
    if distance_sqr_to_player < self.short_range_attack_radius * self.short_range_attack_radius:
        self.transition_state.emit(Type.GROUNDED_SHORT_RANGE_ATTACK)
    elif self.can_perform_long_range_attack():
        self.transition_state.emit(Type.GROUNDED_LONG_RANGE_ATTACK)
    elif self.time_in_state >= self.max_state_time:
        self.transition_state.emit(Type.FLYING_PLAYER_PURSUIT)
    self.time_in_state += delta


func exit_state() -> void:
    pass 


func can_perform_long_range_attack() -> bool:
    var distance_sqr_to_player: float = self.character_body.global_position.distance_squared_to(self.player.global_position)
    return distance_sqr_to_player <= self.long_range_attack_distance * self.long_range_attack_distance
