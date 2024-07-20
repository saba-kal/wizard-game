extends BirdBossAIState

@export var min_time_in_state: float = 3.0
@export var max_time_in_state: float = 15.0
@export var short_range_attack_min_distance: float = 0
@export var short_range_attack_max_distance: float = 2.5
@export var medium_range_attack_min_distance: float = 3.0
@export var medium_range_attack_max_distance: float = 15.0
@export var long_range_attack_min_distance: float = 18.0
@export var long_range_attack_max_distance: float = 25.0

var time_in_state: float = 0.0


func get_type() -> Type:
    return Type.GROUNDED_PLAYER_PURSUIT


func enter_state() -> void:
    self.shared_data.pursue_target_ai.set_enabled(true)
    self.shared_data.fly_to_target_ai.set_enabled(false)
    self.time_in_state = 0


func process_state(delta: float) -> void:

    self.shared_data.pursue_target_ai.set_target(self.shared_data.player.global_position)
    if self.time_in_state < self.min_time_in_state:
        self.time_in_state += delta
        return

    if self.can_attack(self.short_range_attack_min_distance, self.short_range_attack_max_distance):
        self.transition_state.emit(Type.GROUNDED_SHORT_RANGE_ATTACK)
    elif self.can_attack(self.medium_range_attack_min_distance, self.medium_range_attack_max_distance):
        self.transition_state.emit(Type.GROUNDED_MEDIUM_RANGE_ATTACK)
    elif (self.can_attack(self.long_range_attack_min_distance, self.long_range_attack_max_distance) && 
        self.shared_data.long_range_attack_cooldown < self.shared_data.time_since_long_range_attack):
        self.transition_state.emit(Type.GROUNDED_LONG_RANGE_ATTACK)
    elif self.time_in_state >= self.max_time_in_state:
        self.transition_state.emit(Type.FLYING_RISE_UP)

    self.time_in_state += delta


func exit_state() -> void:
    pass 


func is_flying() -> bool:
    return false


func can_attack(min_range: float, max_range: float) -> bool:
    return self.shared_functions.player_is_inside_range(min_range, max_range)
