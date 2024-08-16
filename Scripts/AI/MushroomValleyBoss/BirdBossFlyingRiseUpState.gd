extends BirdBossAIState

var rise_position_offset: float = 5.0
var flight_start_delay: float = 1.0


func get_type() -> Type:
    return Type.FLYING_RISE_UP


func enter_state() -> void:
    self.shared_data.pursue_target_ai.set_enabled(false)
    self.shared_data.fly_to_target_ai.set_enabled(false)

    var foward_direction: Vector3 = self.shared_data.character_body.basis.z * self.rise_position_offset
    var target_position: Vector3 = self.shared_data.character_body.global_position + foward_direction
    target_position.y = self.shared_data.fly_to_target_ai.min_flight_height

    # Carry over the velocity from the nav agent.
    await get_tree().create_timer(self.flight_start_delay).timeout
    self.shared_data.fly_to_target_ai.set_enabled(true)
    self.shared_data.fly_to_target_ai.current_velocity = self.shared_data.pursue_target_ai.nav_agent.velocity
    self.shared_data.fly_to_target_ai.set_target(target_position)


func process_state(delta: float) -> void:
    if self.shared_data.fly_to_target_ai.is_active && self.shared_data.fly_to_target_ai.target_reached():
        self.transition_state.emit(Type.FLYING_IDLE)


func exit_state() -> void:
    pass


func is_flying() -> bool:
    return true
