class_name MushroomBirdBossAI extends CharacterBody3D

signal state_changed(old_state: BirdBossAIState.Type, new_state: BirdBossAIState.Type)

@export var hover_positions: Array[Marker3D] = []

@onready var states_container: Node = $States
@onready var pursue_target_ai: PursueTargetAI = $PursueTargetAI
@onready var fly_to_target_ai: FlyToTargetAI = $FlyToTargetAI
@onready var debug_text: DebugText = $DebugText

var time_since_last_state_change: float = 0
var boss_states: Array = []
var current_state: BirdBossAIState


func _ready() -> void:
    var player: Node3D = self.get_tree().get_first_node_in_group("Player")
    self.boss_states = self.states_container.get_children()
    for state: BirdBossAIState in self.boss_states:
        state.init_state(
            self, 
            self.pursue_target_ai, 
            self.fly_to_target_ai, 
            player, 
            self.hover_positions
        )
        state.transition_state.connect(self.on_state_transition)
    self.current_state = self.get_state(BirdBossAIState.Type.GROUNDED_IDLE)
    self.current_state.enter_state()


func _process(delta: float) -> void:

    self.current_state.process_state(delta)
    self.update_debug_text()
    self.time_since_last_state_change += delta


func on_state_transition(new_state_type: BirdBossAIState.Type) -> void:

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
    return null


func update_debug_text() -> void:
    var args: Array = [BirdBossAIState.Type.keys()[self.current_state.get_type()], self.time_since_last_state_change]
    var text: String = "Current State: %s\nTime since state change: %.2f" % args
    self.debug_text.set_text(text)
