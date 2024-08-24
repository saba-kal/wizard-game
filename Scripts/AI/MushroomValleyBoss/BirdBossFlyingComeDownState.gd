extends BirdBossAIState

@export_flags_3d_physics var ground_check_collision_mask: int = 1

var come_down_position_offset: float = 5.0
var exit_state_delay: float = 2.0
var time_since_target_reached: float = 0.0


func get_type() -> Type:
    return Type.FLYING_COME_DOWN


func enter_state() -> void:
    self.time_since_target_reached = 0.0
    self.shared_data.pursue_target_ai.set_enabled(false)
    self.shared_data.fly_to_target_ai.set_enabled(true)
    self.shared_data.fly_to_target_ai.set_look_at_enabled(false)

    var foward_direction: Vector3 = self.shared_data.character_body.basis.z * self.come_down_position_offset
    var target_position: Vector3 = self.shared_data.character_body.global_position + foward_direction
    target_position = self.get_ground_ray_position(target_position)

    self.shared_data.fly_to_target_ai.set_target(target_position, true)


func process_state(delta: float) -> void:
    if self.shared_data.fly_to_target_ai.target_reached():
        if self.time_since_target_reached >= self.exit_state_delay:
            self.transition_state.emit(Type.GROUNDED_PLAYER_PURSUIT)
        self.time_since_target_reached += delta


func exit_state() -> void:
    self.shared_data.fly_to_target_ai.set_look_at_enabled(true)


func is_flying() -> bool:
    return true


func get_ground_ray_position(from_pos: Vector3) -> Vector3:
    var to_pos: Vector3 = from_pos
    to_pos.y -= 100
    var worldspace = self.shared_data.character_body.get_world_3d().direct_space_state
    var query = PhysicsRayQueryParameters3D.create(from_pos, to_pos, self.ground_check_collision_mask)
    var result = worldspace.intersect_ray(query)
    if result:
        var ground_pos: Vector3 = result["position"]
        ground_pos.y += 0.2 # IDK why, but the height needs a bit of an offset. otherwise, the boss's feet clip through the ground.
        return ground_pos
    else:
        from_pos.y = self.shared_data.player.global_position.y
        return from_pos
