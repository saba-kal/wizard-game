extends BirdBossAIState

var target_position: Vector3


func get_type() -> Type:
    return Type.FLYING_LOCATION_PURSUIT


func enter_state() -> void:
    self.pursue_target_ai.set_enabled(false)
    self.fly_to_target_ai.set_enabled(true)    

    if len(self.hover_positions) == 0:
        printerr("Hover positions not set on mushroom valley boss. Unable to set state to FLYING_LOCATION_PURSUIT")
        self.transition_state.emit(Type.FLYING_PLAYER_PURSUIT)
    else:
        self.target_position = self.hover_positions.pick_random().global_position


func process_state(delta: float) -> void:
    self.fly_to_target_ai.set_target(self.current_hover_position.global_position)
    if self.fly_to_target_ai.target_reached():
        self.transition_state.emit(Type.FLYING_IDLE)


func exit_state() -> void:
    pass
