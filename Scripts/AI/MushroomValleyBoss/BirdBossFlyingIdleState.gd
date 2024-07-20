extends BirdBossAIState

@export var boss_activation_radius: float = 30.0
@export var wait_time_before_attack: float = 2.0
@export var short_range_attack_min_distance: float = 0.0
@export var short_range_attack_max_distance: float = 12.0
@export var medium_range_attack_min_distance: float = 13.0
@export var medium_range_attack_max_distance: float = 20.0
@export var long_range_attack_min_distance: float = 21.0
@export var long_range_attack_max_distance: float = 35.0

var time_in_state: float = 0


func get_type() -> Type:
    return Type.FLYING_IDLE


func enter_state() -> void:
    self.shared_data.pursue_target_ai.set_enabled(false)
    self.shared_data.fly_to_target_ai.set_enabled(true)
    self.shared_data.fly_to_target_ai.set_target(self.shared_data.character_body.global_position)
    self.time_in_state = 0


func process_state(delta: float) -> void:

    self.time_in_state += delta
    self.shared_functions.look_at_player(delta)

    if self.time_in_state < self.wait_time_before_attack:
        return

    if self.can_attack(self.short_range_attack_min_distance, self.short_range_attack_max_distance):
        self.transition_state.emit(Type.FLYING_SHORT_RANGE_ATTACK)
    elif self.can_attack(self.medium_range_attack_min_distance, self.medium_range_attack_max_distance):
        self.transition_state.emit(Type.FLYING_MEDIUM_RANGE_ATTACK)
    elif (self.can_attack(self.long_range_attack_min_distance, self.long_range_attack_max_distance) && 
        self.shared_data.long_range_attack_cooldown < self.shared_data.time_since_long_range_attack):
        self.transition_state.emit(Type.FLYING_LONG_RANGE_ATTACK)
    else:
        var random_state: Type = [Type.FLYING_PLAYER_PURSUIT, Type.FLYING_LOCATION_PURSUIT].pick_random()
        self.transition_state.emit(random_state)


func exit_state() -> void:
    pass


func is_flying() -> bool:
    return true


func can_attack(min_range: float, max_range: float) -> bool:
    return self.shared_functions.player_is_inside_range(min_range, max_range)
