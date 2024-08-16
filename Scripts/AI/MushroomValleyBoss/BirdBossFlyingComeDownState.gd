extends BirdBossAIState

var come_down_position_offset: float = 5.0
var exit_state_delay: float = 2.0
var time_since_target_reached: float = 0.0


func get_type() -> Type:
    return Type.FLYING_COME_DOWN


func enter_state() -> void:
    self.time_since_target_reached = 0.0
    self.shared_data.pursue_target_ai.set_enabled(false)
    self.shared_data.fly_to_target_ai.set_enabled(true)

    var foward_direction: Vector3 = self.shared_data.character_body.basis.z * self.come_down_position_offset
    var target_position: Vector3 = self.shared_data.character_body.global_position + foward_direction

    # Since the boss is on flat ground, we can just grab the player Y position to get the ground height.
    target_position.y = self.shared_data.player.global_position.y + 1.5 # Accounts for player character height.
    self.shared_data.fly_to_target_ai.set_target(target_position, true)


func process_state(delta: float) -> void:
    if self.shared_data.fly_to_target_ai.target_reached():
        if self.time_since_target_reached >= self.exit_state_delay:
            self.transition_state.emit(Type.GROUNDED_PLAYER_PURSUIT)
        self.time_since_target_reached += delta


func exit_state() -> void:
    pass


func is_flying() -> bool:
    return true
