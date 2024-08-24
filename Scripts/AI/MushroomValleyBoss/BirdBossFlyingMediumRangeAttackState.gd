extends BirdBossAIState

@export var attack_finish_wait_time: float = 1.0
@export var medium_attack: AreaAttack

var time_since_attack_finished: float = 0.0


func get_type() -> Type:
    return Type.FLYING_MEDIUM_RANGE_ATTACK


func enter_state() -> void:
    self.shared_data.pursue_target_ai.set_enabled(false)
    self.shared_data.fly_to_target_ai.set_enabled(false)
    self.medium_attack.perform_attack()
    self.time_since_attack_finished = 0


func process_state(delta: float) -> void:
    if !self.medium_attack.is_attacking:
        if self.time_since_attack_finished >= self.attack_finish_wait_time:
            self.transition_state.emit(Type.FLYING_LOCATION_PURSUIT)
        self.time_since_attack_finished += delta


func exit_state() -> void:
    pass


func is_flying() -> bool:
    return true
