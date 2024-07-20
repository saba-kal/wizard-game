class_name MushroomBirdBossAI extends CharacterBody3D

signal state_changed(old_state: BirdBossAIState.Type, new_state: BirdBossAIState.Type)

@export var long_range_attack_cooldown: float = 15.0
@export var hover_positions: Array[Marker3D] = []

@onready var states_container: Node = $States
@onready var pursue_target_ai: PursueTargetAI = $PursueTargetAI
@onready var fly_to_target_ai: FlyToTargetAI = $FlyToTargetAI
@onready var debug_text: DebugText = $DebugText
@onready var health: Health = $Health

var time_since_last_state_change: float = 0
var boss_states: Array = []
var current_state: BirdBossAIState
var player: Node3D


func _ready() -> void:
    self.health.health_lost.connect(self.on_health_lost)
    self.player = self.get_tree().get_first_node_in_group("Player")
    self.boss_states = self.states_container.get_children()
    
    var shared_data = BirdBossAISharedData.new(
        self,
        self.pursue_target_ai, 
        self.fly_to_target_ai, 
        self.player, 
        self.hover_positions,
        self.long_range_attack_cooldown)
    for state: BirdBossAIState in self.boss_states:
        state.init_state(shared_data)
        state.transition_state.connect(self.transition_to_state)
    self.current_state = self.get_state(BirdBossAIState.Type.GROUNDED_IDLE)
    self.current_state.enter_state()


func _physics_process(delta: float) -> void:
    self.current_state.process_state(delta)


func _process(delta: float) -> void:
    self.update_debug_text()
    self.time_since_last_state_change += delta


func on_health_lost() -> void:
    if self.current_state.is_flying():
        self.transition_to_state(BirdBossAIState.Type.FLYING_FALL)
    else:
        self.transition_to_state(BirdBossAIState.Type.DEAD)


func transition_to_state(new_state_type: BirdBossAIState.Type) -> void:

    var old_state_type: BirdBossAIState.Type = self.current_state.get_type()
    if old_state_type == new_state_type:
        return

    self.current_state.exit_state()
    self.current_state = self.get_state(new_state_type)
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
        self.global_position.distance_to(self.player.global_position)
    ]
    var text: String = "Current State: %s\nTime since state change: %.2f\nDistance to player: %.2f" % args
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
