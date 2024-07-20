extends BirdBossAIState


func get_type() -> Type:
    return Type.DEAD


func enter_state() -> void:
    self.shared_data.pursue_target_ai.set_enabled(false)
    self.shared_data.fly_to_target_ai.set_enabled(false)


func process_state(delta: float) -> void:
    pass # Do nothing since boss is dead.


func exit_state() -> void:
    pass


func is_flying() -> bool:
    return false
