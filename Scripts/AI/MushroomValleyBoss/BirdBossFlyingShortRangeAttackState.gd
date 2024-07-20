extends BirdBossAIState

enum SubState {
    DIVING,
    CLIMBING
}

@export var short_range_attack: AreaAttack

var dive_height: float = 1.0
var distance_before_attacking: float = 3.0
var current_sub_state: SubState = SubState.DIVING
var climb_position: Vector3
var initial_player_position: Vector3

func get_type() -> Type:
    return Type.FLYING_SHORT_RANGE_ATTACK


func enter_state() -> void:
    self.shared_data.pursue_target_ai.set_enabled(false)
    self.shared_data.fly_to_target_ai.set_enabled(true)

    var dive_position: Vector3 = self.get_dive_to_position()
    self.shared_data.fly_to_target_ai.set_target(dive_position, true)
    self.current_sub_state = SubState.DIVING

    self.climb_position = self.get_climb_position()
    self.initial_player_position = self.shared_data.player.global_position


func process_state(delta: float) -> void:
    if !self.can_attack(self.distance_before_attacking):
        return

    match self.current_sub_state: 
        SubState.DIVING:
            self.short_range_attack.perform_attack()
            self.current_sub_state = SubState.CLIMBING
            self.shared_data.fly_to_target_ai.set_target(self.climb_position)
        SubState.CLIMBING:
            self.transition_state.emit(Type.FLYING_LOCATION_PURSUIT)


func exit_state() -> void:
    pass


func is_flying() -> bool:
    return true


func get_dive_to_position() -> Vector3:
    var dive_position: Vector3 = self.shared_data.player.global_position
    dive_position.y += self.dive_height
    return dive_position


func get_climb_position() -> Vector3:
    # Pretend player is at the same height as the boss.
    var floating_player_position = self.shared_data.player.global_position
    floating_player_position.y = self.shared_data.character_body.global_position.y
    var direction_to_player: Vector3 = (self.shared_data.character_body.global_position - floating_player_position)
    return self.shared_data.character_body.global_position - direction_to_player * 2


func can_attack(range: float) -> bool:
    var distance_sqr_to_player: float = self.shared_data.character_body.global_position.distance_squared_to(self.initial_player_position)
    return distance_sqr_to_player <= range * range
