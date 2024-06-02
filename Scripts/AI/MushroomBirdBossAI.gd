class_name MushroomBirdBossAI extends CharacterBody3D

signal state_changed(old_state: State, new_state: State)

enum State {
    GROUNDED_IDLE,
    GROUNDED_PLAYER_PURSUIT,
    GROUNDED_LOCATION_PURSUIT,
    GROUNDED_SHORT_RANGE_ATTACK,
    FLYING_IDLE,
    FLYING_PLAYER_PURSUIT,
    FLYING_PLAYER_CIRCLE,
    FLYING_LOCATION_PURSUIT,
    FLYING_SHORT_RANGE_ATTACK,
    DEAD
}

@export var boss_activation_radius: float = 30.0
@export var max_time_per_state: float = 10.0
@export var flying_height: float = 5.0
@export var short_range_attack_radius: float = 2.5


@onready var pursue_target_ai: PursueTargetAI = $PursueTargetAI
@onready var fly_to_target_ai: FlyToTargetAI = $FlyToTargetAI
@onready var area_attack: AreaAttack = $AreaAttack
@onready var debug_text: DebugText = $DebugText
@onready var start_position: Vector3 = self.global_position

var player: Node3D
var current_state: State = State.GROUNDED_IDLE
var time_since_last_state_change: float = 0


func _ready() -> void:
    self.player = self.get_tree().get_first_node_in_group("Player")
    self.area_attack.attack_finished.connect(self.on_attack_finished)


func _process(delta: float) -> void:
    match self.current_state:
        State.GROUNDED_IDLE:
            self.grounded_idle()
        State.GROUNDED_PLAYER_PURSUIT:
            self.grounded_player_pursuit()
        State.GROUNDED_LOCATION_PURSUIT:
            self.grounded_location_pursuit()
        State.GROUNDED_SHORT_RANGE_ATTACK:
            self.grounded_short_range_attack()
        State.FLYING_IDLE:
            self.flying_idle()
        State.FLYING_PLAYER_PURSUIT:
            self.flying_player_pursuit()
        State.FLYING_PLAYER_CIRCLE:
            self.flying_player_circle()
        State.FLYING_LOCATION_PURSUIT:
            self.flying_location_pursuit()
        State.FLYING_SHORT_RANGE_ATTACK:
            self.flying_short_range_attack()
        State.DEAD:
            self.dead()
    self.update_debug_text()
    self.time_since_last_state_change += delta


#region State Processors


func grounded_idle() -> void:
    self.pursue_target_ai.set_enabled(false)
    self.fly_to_target_ai.set_enabled(false)
    if self.is_player_inside_attack_zone():
        self.set_state(State.FLYING_PLAYER_PURSUIT)


func grounded_player_pursuit() -> void:
    self.fly_to_target_ai.set_enabled(false)

    self.pursue_target_ai.set_enabled(true)
    self.pursue_target_ai.set_target(self.player.global_position)

    var distance_sqr_to_player: float = self.global_position.distance_squared_to(self.player.global_position)
    if distance_sqr_to_player < self.short_range_attack_radius * self.short_range_attack_radius:
        self.set_state(State.GROUNDED_SHORT_RANGE_ATTACK)
    elif self.time_since_last_state_change >= self.max_time_per_state:
        self.set_state(State.FLYING_PLAYER_PURSUIT)


func grounded_location_pursuit() -> void:
    pass


func grounded_short_range_attack() -> void:
    self.process_short_range_attack()


func flying_idle() -> void:
    pass


func flying_player_pursuit() -> void:
    self.pursue_target_ai.set_enabled(false)

    self.fly_to_target_ai.set_enabled(true)
    self.fly_to_target_ai.set_target(self.player.global_position + Vector3(0, self.flying_height, 0))

    if self.fly_to_target_ai.target_reached():
        self.set_state(State.FLYING_PLAYER_CIRCLE)
    elif self.time_since_last_state_change >= self.max_time_per_state:
        self.set_state(State.GROUNDED_PLAYER_PURSUIT)


func flying_player_circle() -> void:
    self.pursue_target_ai.set_enabled(false)

    self.fly_to_target_ai.set_enabled(true)
    self.fly_to_target_ai.set_target(self.player.global_position + Vector3(0, self.flying_height, 0))
    self.fly_to_target_ai.set_circular_flight_enabled(true)

    var distance_sqr_to_player: float = self.global_position.distance_squared_to(self.player.global_position)
    if distance_sqr_to_player < self.short_range_attack_radius * self.short_range_attack_radius:
        self.set_state(State.FLYING_SHORT_RANGE_ATTACK)
    elif self.time_since_last_state_change >= self.max_time_per_state:
        self.fly_to_target_ai.set_circular_flight_enabled(false)
        self.set_state(State.GROUNDED_PLAYER_PURSUIT)


func flying_location_pursuit() -> void:
    pass


func flying_short_range_attack() -> void:
    self.process_short_range_attack()


func dead() -> void:
    pass

#endregion


#region Common Functions


func process_short_range_attack():
    self.pursue_target_ai.set_enabled(false)
    self.fly_to_target_ai.set_enabled(false)
    if self.area_attack.is_attacking:
        return
    self.area_attack.perform_attack()


func on_attack_finished() -> void:
    if self.current_state == State.GROUNDED_SHORT_RANGE_ATTACK:
        self.set_state(State.GROUNDED_PLAYER_PURSUIT)
    else:
        self.set_state(State.FLYING_PLAYER_PURSUIT)


func set_state(new_state: State) -> void:
    var old_state: State = self.current_state
    self.current_state = new_state
    self.time_since_last_state_change = 0
    self.state_changed.emit(old_state, new_state)


func is_player_inside_attack_zone() -> bool:
    return (
        self.start_position.distance_squared_to(self.player.global_position) < 
        self.boss_activation_radius * self.boss_activation_radius
    )


func update_debug_text() -> void:
    var args: Array = [State.keys()[self.current_state], self.time_since_last_state_change]
    var text: String = "Current State: %s\nTime since state change: %.2f" % args
    self.debug_text.set_text(text)

#endregion
