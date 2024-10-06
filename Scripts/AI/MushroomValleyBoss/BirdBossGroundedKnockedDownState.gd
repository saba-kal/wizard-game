extends BirdBossAIState

@export var duration: float = 5.0

var time_in_state: float = 0


func get_type() -> Type:
    return Type.GROUNDED_KNOCKED_OUT


func enter_state() -> void:
    self.time_in_state = 0
    self.shared_data.pursue_target_ai.set_enabled(false)
    self.shared_data.fly_to_target_ai.set_enabled(false)


func process_state(delta: float) -> void:
    if self.time_in_state < self.duration:
        self.time_in_state += delta
    else:
        self.transition_state.emit(Type.GROUNDED_PLAYER_PURSUIT)


func exit_state() -> void:
    pass


func is_flying() -> bool:
    return false
