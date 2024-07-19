extends BirdBossAIState

@export var boss_activation_radius: float = 30.0


func get_type() -> Type:
    return Type.GROUNDED_IDLE


func enter_state() -> void:
    self.pursue_target_ai.set_enabled(false)
    self.fly_to_target_ai.set_enabled(false)


func process_state(delta: float) -> void:
    if self.is_player_inside_attack_zone():
        self.transition_state.emit(Type.FLYING_PLAYER_PURSUIT)


func exit_state() -> void:
    pass


func is_player_inside_attack_zone() -> bool:
    return (
        self.start_position.distance_squared_to(self.player.global_position) < 
        self.boss_activation_radius * self.boss_activation_radius
    )
