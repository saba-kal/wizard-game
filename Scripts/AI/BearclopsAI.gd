class_name BearclopsAI extends CharacterBody3D

signal state_changed(agent: BearclopsAI, old_state: State, new_state: State)

enum State {IDLE, PURSUIT, DEAD}

@export var detect_radius: float = 10.0

@onready var health: Health = $Health
@onready var spawn_position: Vector3 = self.global_position
@onready var pursue_target_ai: PursueTargetAI = $PursueTargetAI

var player: Node3D
var current_state: State = State.IDLE


func _ready():
    self.player = self.get_tree().get_first_node_in_group("Player")
    self.health.health_lost.connect(self.on_health_lost)


func _physics_process(delta):
    match self.current_state:
        State.IDLE:
            self.idle()
        State.PURSUIT:
            self.persue_player()
        State.DEAD:
            self.pursue_target_ai.set_enabled(false)


func idle():
    self.pursue_target_ai.set_enabled(true)
    self.pursue_target_ai.set_target(self.spawn_position)
    if self.global_position.distance_squared_to(self.player.global_position) <= self.detect_radius * self.detect_radius:
        self.set_state(State.PURSUIT)


func persue_player():
    self.pursue_target_ai.set_enabled(true)
    if self.global_position.distance_squared_to(self.player.global_position) > self.detect_radius * self.detect_radius:
        self.set_state(State.IDLE)
    else:
        self.pursue_target_ai.set_target(self.player.global_position)


func on_health_lost():
    self.set_state(State.DEAD)


func set_state(new_state: State):
    var old_state = self.current_state
    self.current_state = new_state
    self.state_changed.emit(self, old_state, new_state)
