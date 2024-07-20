extends BirdBossAIState

@export var boss_activation_radius: float = 30.0


func get_type() -> Type:
    return Type.GROUNDED_IDLE


func enter_state() -> void:
    self.shared_data.pursue_target_ai.set_enabled(false)
    self.shared_data.fly_to_target_ai.set_enabled(false)


func process_state(delta: float) -> void:
    if self.is_player_inside_attack_zone():
        self.transition_state.emit(Type.FLYING_RISE_UP)


func exit_state() -> void:
    pass


func is_player_inside_attack_zone() -> bool:
    return (
        self.shared_data.start_position.distance_squared_to(self.shared_data.player.global_position) < 
        self.boss_activation_radius * self.boss_activation_radius
    )


func is_flying() -> bool:
    return false
