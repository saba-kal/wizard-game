extends BirdBossAIState

@export var medium_attack: AreaAttack


func get_type() -> Type:
    return Type.FLYING_MEDIUM_RANGE_ATTACK


func enter_state() -> void:
    self.shared_data.pursue_target_ai.set_enabled(false)
    self.shared_data.fly_to_target_ai.set_enabled(true)
    self.shared_data.fly_to_target_ai.set_target(self.shared_data.character_body.global_position)
    self.medium_attack.perform_attack()


func process_state(delta: float) -> void:
    if !self.medium_attack.is_attacking:
        self.transition_state.emit(Type.FLYING_LOCATION_PURSUIT)


func exit_state() -> void:
    pass


func is_flying() -> bool:
    return true
