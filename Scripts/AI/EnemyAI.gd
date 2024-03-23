class_name EnemyAI extends CharacterBody3D

signal state_changed(agent: EnemyAI, old_state: State, new_state: State)
signal attack_started()

enum State {WANDER, PERSUIT, STUN, ATTACK, DEAD}

@export var detect_radius: float = 10.0
@export var ai_wander_area: AIWanderArea
@export var ai_default_attack: AIDefaultAttack

@onready var pursue_target_ai: PursueTargetAI = $PursueTargetAI
@onready var health: Health = $Health
@onready var spawn_position: Vector3 = self.global_position

var player: Node3D
var current_state: State = State.WANDER


func _ready():
    self.player = self.get_tree().get_first_node_in_group("Player")
    self.health.health_lost.connect(self.on_health_lost)
    if self.ai_wander_area != null:
        call_deferred("register_agent_to_wander_area")


func register_agent_to_wander_area():
    await get_tree().physics_frame
    self.ai_wander_area.register_agent(self)


func _physics_process(delta: float):
    match self.current_state:
        State.WANDER:
            self.wander()
        State.PERSUIT:
            self.persue_player()
        State.STUN:
            self.remain_still()
        State.ATTACK:
            self.attack(delta)
        State.DEAD:
            self.remain_still()


func persue_player():
    self.pursue_target_ai.set_enabled(true)
    if self.global_position.distance_squared_to(self.player.global_position) > self.detect_radius * self.detect_radius:
        self.set_state(State.WANDER)
    elif self.ai_default_attack != null && self.ai_default_attack.is_in_range():
        self.set_state(State.ATTACK)
    else:
        self.pursue_target_ai.set_target(self.player.global_position)


func wander():
    self.pursue_target_ai.set_enabled(true)
    if self.global_position.distance_squared_to(self.player.global_position) <= self.detect_radius * self.detect_radius:
        self.set_state(State.PERSUIT)
    elif self.ai_wander_area != null:
        self.pursue_target_ai.set_target(self.ai_wander_area.get_next_wonder_position(self))
    else:
        self.pursue_target_ai.set_target(self.spawn_position)


func remain_still():
    self.pursue_target_ai.set_enabled(false)


func attack(delta: float):
    self.pursue_target_ai.set_enabled(false)
    if self.global_position.distance_squared_to(self.player.global_position) > self.detect_radius * self.detect_radius:
        self.set_state(State.WANDER)
        return
    self.pursue_target_ai.set_target(self.player.global_position)
    self.pursue_target_ai.look_at_target(delta)
    if !self.ai_default_attack.is_attacking:
        if self.ai_default_attack.is_in_range():
            self.ai_default_attack.perform_attack()
            self.attack_started.emit()
        else:
            self.set_state(State.PERSUIT)


func set_state(new_state: State):
    var old_state = self.current_state
    self.current_state = new_state
    self.state_changed.emit(self, old_state, new_state)


func on_health_lost():
    self.set_state(State.DEAD)
