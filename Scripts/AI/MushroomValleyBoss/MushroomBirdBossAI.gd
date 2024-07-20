class_name MushroomBirdBossAI extends CharacterBody3D

signal state_changed(old_state: BirdBossAIState.Type, new_state: BirdBossAIState.Type)

@export var long_range_attack_cooldown: float = 15.0
@export var hover_positions_container: Node3D
@export var starting_action_points: int = 5
@export var max_time_in_grounded_states: float = 20.0

@onready var states_container: Node = $States
@onready var pursue_target_ai: PursueTargetAI = $PursueTargetAI
@onready var fly_to_target_ai: FlyToTargetAI = $FlyToTargetAI
@onready var debug_text: DebugText = $DebugText
@onready var health: Health = $Health
@onready var current_action_points: int = self.starting_action_points

var time_since_last_state_change: float = 0
var time_in_grounded_state: float = 0
var boss_states: Array = []
var current_state: BirdBossAIState
var player: Node3D


func _ready() -> void:
    SignalBus.ballista_projectile_collided.connect(self.on_ballista_projectile_collided)
    self.health.health_lost.connect(self.on_health_lost)
    self.player = self.get_tree().get_first_node_in_group("Player")
    self.boss_states = self.states_container.get_children()

    var hover_positions: Array[Marker3D] = []
    for hover_position: Marker3D in self.hover_positions_container.get_children():
        hover_positions.append(hover_position)

    var shared_data: BirdBossAISharedData = BirdBossAISharedData.new(
        self,
        self.pursue_target_ai, 
        self.fly_to_target_ai, 
        self.player, 
        hover_positions,
        self.long_range_attack_cooldown)
    var shared_functions: BirdBossAISharedFunctions = BirdBossAISharedFunctions.new(shared_data)

    for state: BirdBossAIState in self.boss_states:
        state.init_state(shared_data, shared_functions)
        state.transition_state.connect(self.transition_to_state)
    self.current_state = self.get_state(BirdBossAIState.Type.GROUNDED_IDLE)
    self.current_state.enter_state()


func _physics_process(delta: float) -> void:
    self.current_state.process_state(delta)


func _process(delta: float) -> void:
    self.update_debug_text()
    self.time_since_last_state_change += delta
    if !self.current_state.is_flying():
        self.time_in_grounded_state += delta


func on_health_lost() -> void:
    if self.current_state.is_flying():
        self.transition_to_state(BirdBossAIState.Type.FLYING_FALL)
    else:
        self.transition_to_state(BirdBossAIState.Type.DEAD)


func on_ballista_projectile_collided(body: Node3D) -> void:
    if body == self && self.current_state.is_flying():
        self.transition_to_state(BirdBossAIState.Type.FLYING_FALL)


func transition_to_state(new_state_type: BirdBossAIState.Type) -> void:

    var old_state_type: BirdBossAIState.Type = self.current_state.get_type()
    if old_state_type == new_state_type:
        return

    self.current_state.exit_state()
    self.current_state = self.get_state(new_state_type)

    self.current_action_points += self.current_state.action_points

    # Boss used up all of their action points. So, they must fly down to the ground.
    if self.current_action_points <= 0:
        self.current_action_points = self.starting_action_points
        self.time_in_grounded_state = 0
        self.current_state = self.get_state(BirdBossAIState.Type.FLYING_COME_DOWN)
    # Boss spent maximum amount of time in grounded state. They should fly up.
    elif !self.current_state.is_flying() && self.time_in_grounded_state >= self.max_time_in_grounded_states:
        self.current_action_points = self.starting_action_points
        self.current_state = self.get_state(BirdBossAIState.Type.FLYING_RISE_UP)

    self.current_state.enter_state()

    self.state_changed.emit(old_state_type, new_state_type)
    self.time_since_last_state_change = 0


func get_state(type: BirdBossAIState.Type) -> BirdBossAIState:
    for state: BirdBossAIState in self.boss_states:
        if state.get_type() == type:
            return state
    printerr("Could not fine boss state of type " + BirdBossAIState.Type.keys()[type])
    return null


func update_debug_text() -> void:
    var args: Array = [
        BirdBossAIState.Type.keys()[self.current_state.get_type()], 
        self.time_since_last_state_change,
        self.global_position.distance_to(self.player.global_position),
        self.current_action_points
    ]
    var text: String = (
        "Current State: %s\n" + 
        "Time since state change: %.2f\n" + 
        "Distance to player: %.2f\n" + 
        "Action points: %d"
    ) % args

    self.debug_text.set_text(text)


class BirdBossAISharedData:

    var character_body: CharacterBody3D
    var pursue_target_ai: PursueTargetAI
    var fly_to_target_ai: FlyToTargetAI
    var player: Node3D
    var hover_positions: Array[Marker3D] = []
    var long_range_attack_cooldown: float

    var start_position: Vector3
    var time_since_long_range_attack: float = 0


    func _init(
        char_body: CharacterBody3D,
        pursue_ai: PursueTargetAI,
        fly_ai: FlyToTargetAI,
        plr: Node3D,
        hov_positions: Array[Marker3D],
        long_rng_cooldown: float
    ) -> void:
        self.character_body = char_body
        self.pursue_target_ai = pursue_ai
        self.fly_to_target_ai = fly_ai
        self.player = plr
        self.hover_positions = hov_positions
        self.long_range_attack_cooldown = long_rng_cooldown
        self.start_position = self.character_body.global_position


class BirdBossAISharedFunctions:

    var shared_data: BirdBossAISharedData


    func _init(data: BirdBossAISharedData):
        self.shared_data = data


    func player_is_inside_range(min_range: float, max_range: float) -> bool:
        var distance_sqr_to_player: float = self.shared_data.character_body.global_position.distance_squared_to(self.shared_data.player.global_position)
        return distance_sqr_to_player >= min_range * min_range && distance_sqr_to_player <= max_range * max_range


    func long_range_attack_is_ready() -> bool:
        return self.shared_data.time_since_long_range_attack >= self.shared_data.long_range_attack_cooldown


    func look_at_player(delta: float) -> void:
        # Even if the pursue target AI is disabled, we can re-use its code for looking at target positions.
        self.shared_data.pursue_target_ai.set_target(self.shared_data.player.global_position)
        self.shared_data.pursue_target_ai.look_at_target(delta)




