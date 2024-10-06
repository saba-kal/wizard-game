extends BirdBossAIState

var last_chosen_pos_index: int = -1


func get_type() -> Type:
    return Type.FLYING_LOCATION_PURSUIT


func enter_state() -> void:
    self.shared_data.pursue_target_ai.set_enabled(false)
    self.shared_data.fly_to_target_ai.set_enabled(true)    

    if len(self.shared_data.hover_positions) == 0:
        printerr("Hover positions not set on mushroom valley boss. Unable to set state to FLYING_LOCATION_PURSUIT")
        self.transition_state.emit(Type.FLYING_PLAYER_PURSUIT)
    else:

        var possible_position_indexes: Array = range(0, len(self.shared_data.hover_positions))
        if self.last_chosen_pos_index > 0:
            possible_position_indexes.remove_at(self.last_chosen_pos_index)

        var index: int = self.get_closest_position_index(possible_position_indexes)
        var target_position: Vector3 = self.shared_data.hover_positions[index].global_position
        self.shared_data.fly_to_target_ai.set_target(target_position)

        # If the boss is already at this location, pick a different one.
        if self.shared_data.fly_to_target_ai.target_reached():
            possible_position_indexes.remove_at(index)
            index = self.get_closest_position_index(possible_position_indexes)
            target_position = self.shared_data.hover_positions[index].global_position
            self.shared_data.fly_to_target_ai.set_target(target_position)

        self.last_chosen_pos_index = index


func process_state(delta: float) -> void:
    if self.shared_data.fly_to_target_ai.target_reached():
        self.transition_state.emit(Type.FLYING_IDLE)


func exit_state() -> void:
    pass


func is_flying() -> bool:
    return true


func get_closest_position_index(possible_position_indexes: Array) -> int:
    var min_distance_sqr: float = 100000000
    var closest_position_index: int = possible_position_indexes[0]
    for i: int in possible_position_indexes:
        var pos: Vector3 = self.shared_data.hover_positions[i].global_position
        var distance_sqr: float = pos.distance_squared_to(self.shared_data.character_body.global_position)
        if distance_sqr < min_distance_sqr:
            min_distance_sqr = distance_sqr
            closest_position_index = i
    return closest_position_index
