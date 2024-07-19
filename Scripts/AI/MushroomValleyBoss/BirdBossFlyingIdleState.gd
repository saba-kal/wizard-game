extends BirdBossAIState

@export var boss_activation_radius: float = 30.0
@export var wait_time_before_attack: float = 2.0
@export var long_range_attack_distance: float = 15.0

var time_in_state: float = 0


func get_type() -> Type:
    return Type.FLYING_IDLE


func enter_state() -> void:
    self.pursue_target_ai.set_enabled(false)
    self.fly_to_target_ai.set_enabled(true)
    self.fly_to_target_ai.set_target(self.global_position)
    self.time_in_state = 0


func process_state(delta: float) -> void:

    self.time_in_state += delta
    self.look_at_player(delta)

    if self.time_in_state < self.wait_time_before_attack:
        return

    if self.can_perform_long_range_attack():
        self.transition_state.emit(Type.FLYING_LONG_RANGE_ATTACK)
    else:
        var random_state: Type = [Type.GROUNDED_PLAYER_PURSUIT, Type.FLYING_LOCATION_PURSUIT].pick_random()
        self.transition_state.emit(random_state)


func exit_state() -> void:
    pass


func look_at_player(delta: float) -> void:
    # Even if the pursue target AI is disabled, we can re-use its code for looking at target positions.
    self.pursue_target_ai.set_target(self.player.global_position)
    self.pursue_target_ai.look_at_target(delta)


func can_perform_long_range_attack() -> bool:
    var distance_sqr_to_player: float = self.character_body.global_position.distance_squared_to(self.player.global_position)
    return distance_sqr_to_player <= self.long_range_attack_distance * self.long_range_attack_distance
