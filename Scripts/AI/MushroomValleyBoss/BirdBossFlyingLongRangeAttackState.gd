extends BirdBossAIState

@export var projectile_attack: ProjectileAttack


func get_type() -> Type:
    return Type.FLYING_LONG_RANGE_ATTACK


func enter_state() -> void:
    self.shared_data.time_since_long_range_attack = 0
    self.shared_data.pursue_target_ai.set_enabled(false)
    self.shared_data.fly_to_target_ai.set_enabled(false)
    self.projectile_attack.perform_attack()


func process_state(delta: float) -> void:
    self.look_at_player(delta)
    if !self.projectile_attack.is_attacking:
        self.transition_state.emit(Type.FLYING_PLAYER_PURSUIT)


func _process(delta: float) -> void:
    #this process function always runs, even if this state is inactive.
    self.shared_data.time_since_long_range_attack += delta


func exit_state() -> void:
    pass


func is_flying() -> bool:
    return true


func look_at_player(delta: float) -> void:
    # Even if the pursue target AI is disabled, we can re-use its code for looking at target positions.
    self.shared_data.pursue_target_ai.set_target(self.shared_data.player.global_position)
    self.shared_data.pursue_target_ai.look_at_target(delta)