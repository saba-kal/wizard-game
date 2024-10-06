extends BirdBossAIState

@export var short_range_attack: AreaAttack


func get_type() -> Type:
    return Type.GROUNDED_SHORT_RANGE_ATTACK


func enter_state() -> void:
    self.shared_data.pursue_target_ai.set_enabled(false)
    self.shared_data.fly_to_target_ai.set_enabled(false)
    self.short_range_attack.perform_attack()


func process_state(delta: float) -> void:
    if !self.short_range_attack.is_attacking:
        self.transition_state.emit(Type.GROUNDED_PLAYER_PURSUIT)


func exit_state() -> void:
    pass


func is_flying() -> bool:
    return false
